//
//  BluetoothScanner.swift
//  Created by Michael Simms on 5/3/22.
//

import Foundation
import CoreBluetooth

/// @brief This class manages the bluetooth session, scanning for peripherals, querying their services, and reporting updated values.
class BluetoothScanner: NSObject, CBPeripheralDelegate, CBCentralManagerDelegate, ObservableObject {
	
	/// @brief List of peripheral objects currently connected.
	@Published var connectedPeripherals: Array<CBPeripheral> = []
	
	/// @brief Apple's Bluetooth interface.
	private var centralManager: CBCentralManager!
	
	/// @brief List of services that we are searching for.
	private var serviceIdsToScanFor: Array<CBUUID> = []
	
	/// @brief Callbacks for when a service is discovered.
	private var manufacturerDataReadCallbacks: Array<(Data) -> Void> = []
	
	/// @brief Callbacks for when a peripheral is discovered.
	private var peripheralDiscoveryCallbacks: Array<(CBPeripheral, String) -> Bool> = []
	
	/// @brief Callbacks for when a service is discovered.
	private var serviceDiscoveryCallbacks: Array<(CBPeripheral, CBUUID) -> Void> = []
	
	/// @brief Callbacks for when a value is updated.
	private var valueUpdatedCallbacks: Array<(CBPeripheral, CBUUID, Data) -> Void> = []
	
	/// @brief Callbacks for when a peripheral disconnects.
	private var peripheralDisconnectedCallbacks: Array<(CBPeripheral) -> Void> = []
	
	///
	/// Internal state management functions
	///
	
	private func startTrackingConnectedPeripheral(peripheral: CBPeripheral) {
		var found = false
		
		for temp in self.connectedPeripherals {
			if temp == peripheral {
				found = true
				break
			}
		}
		
		if !found {
			self.connectedPeripherals.append(peripheral)
			peripheral.delegate = self
		}
	}
	private func stopTrackingConnectedPeripheral(peripheral: CBPeripheral) {
		for (index, value) in self.connectedPeripherals.enumerated() {
			if value == peripheral {
				self.connectedPeripherals.remove(at: index)
				break
			}
		}
	}
	private func isTrackedPeripheral(peripheral: CBPeripheral) -> Bool {
		for temp in self.connectedPeripherals {
			if temp == peripheral {
				return true
			}
		}
		return false
	}
	
	///
	/// Central Manager callbacks
	///
	
	func centralManagerDidUpdateState(_ central: CBCentralManager) {
		if central.state == .poweredOn {
			
			// If services were not specified, then we have to scan for every possible peripheral. This can be useful
			// if we looking for manufacturer data but is inefficient if we're looking for peripherals that properly
			// advertise services.
			if self.serviceIdsToScanFor.count == 0 {
				centralManager.scanForPeripherals(withServices: nil, options: [ CBCentralManagerScanOptionAllowDuplicatesKey: true ] )
			}
			else {
				centralManager.scanForPeripherals(withServices: self.serviceIdsToScanFor, options: [ CBCentralManagerScanOptionAllowDuplicatesKey: true ] )
			}
		}
	}
	func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
		
		// Are we scanning for and connecting to services, or just reading manufacturer data from all peripherals?
		if self.serviceIdsToScanFor.count == 0 {
			
			let manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey]
			if manufacturerData != nil {
				let data = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data
				
				if data != nil && data!.count >= 0 {
					for cb in self.manufacturerDataReadCallbacks {
						cb(data!)
					}
				}
			}
		}
		else {
			
			// Notify callbacks
			for cb in self.peripheralDiscoveryCallbacks {
				
				// If the callback returns true then we should connect to the peripheral.
				if let name = advertisementData["kCBAdvDataLocalName"] as? String {
					if cb(peripheral, name) {
						self.centralManager.connect(peripheral, options: nil)
						self.startTrackingConnectedPeripheral(peripheral: peripheral)
					}
				}
			}
		}
	}
	func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
		
		// Discover any relevant services.
		if self.isTrackedPeripheral(peripheral: peripheral) {
			peripheral.discoverServices(self.serviceIdsToScanFor)
		}
	}
	func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
	}
	func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
		
		// Remove the peripheral from the connected list.
		self.stopTrackingConnectedPeripheral(peripheral: peripheral)
		
		// Call the callbacks
		for cb in self.peripheralDisconnectedCallbacks {
			cb(peripheral)
		}
	}
	
	///
	/// Peripheral callbacks
	///
	
	func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
		
		// Enumerate the discovered services.
		if let services = peripheral.services {
			for service in services {
				
				// Make sure this is a service that we're interested in.
				for serviceIdToScanFor in self.serviceIdsToScanFor {
					if serviceIdToScanFor == service.uuid {
						
						// Notify callbacks.
						for cb in self.serviceDiscoveryCallbacks {
							cb(peripheral, service.uuid)
						}
						
						// Discover characteristics.
						peripheral.discoverCharacteristics(nil, for: service)
					}
				}
			}
		}
	}
	func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
		if let characteristics = service.characteristics {
			for characteristic in characteristics {
				peripheral.setNotifyValue(true, for: characteristic)
				peripheral.readValue(for: characteristic)
			}
		}
	}
	func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
		for cb in self.valueUpdatedCallbacks {
			if characteristic.value != nil {
				cb(peripheral, characteristic.service!.uuid, characteristic.value!)
			}
		}
	}
	func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
	}
	
	///
	/// Public interface for this class
	///
	
	func startScanningForManufactuerData(manufacturerDataRead: Array<(Data) -> Void>) {
		self.manufacturerDataReadCallbacks = manufacturerDataRead
		self.serviceIdsToScanFor = []
		self.peripheralDiscoveryCallbacks = []
		self.serviceDiscoveryCallbacks = []
		self.valueUpdatedCallbacks = []
		self.peripheralDisconnectedCallbacks = []
		self.centralManager = CBCentralManager(delegate: self, queue: nil)
	}
	func startScanningForServices(serviceIdsToScanFor: Array<CBUUID>, peripheralCallbacks: Array<(CBPeripheral, String) -> Bool>, serviceCallbacks: Array<(CBPeripheral, CBUUID) -> Void>, valueUpdatedCallbacks: Array<(CBPeripheral, CBUUID, Data) -> Void>, peripheralDisconnectedCallbacks: Array<(CBPeripheral) -> Void>) {
		self.manufacturerDataReadCallbacks = []
		self.serviceIdsToScanFor = serviceIdsToScanFor
		self.peripheralDiscoveryCallbacks = peripheralCallbacks
		self.serviceDiscoveryCallbacks = serviceCallbacks
		self.valueUpdatedCallbacks = valueUpdatedCallbacks
		self.peripheralDisconnectedCallbacks = []
		self.centralManager = CBCentralManager(delegate: self, queue: nil)
	}
	func stopScanning() {
		self.centralManager = nil
	}
}
