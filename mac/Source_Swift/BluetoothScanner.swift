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

	/// @brief Callbacks for when a peripheral is discovered.
	private var peripheralDiscoveryCallbacks: Array<(String) -> Bool> = []

	/// @brief Callbacks for when a service is discovered.
	private var serviceDiscoveryCallbacks: Array<(CBUUID) -> Void> = []

	/// @brief Callbacks for when a value is updated.
	private var valueUpdatedCallbacks: Array<(CBPeripheral, CBUUID, Data) -> Void> = []

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
			centralManager.scanForPeripherals(withServices: self.serviceIdsToScanFor, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
		}
	}
	func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
	}
	func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {

		// Notify callbacks
		for cb in self.peripheralDiscoveryCallbacks {

			// If the callback returns true then we should connect to the peripheral.
			if cb(advertisementData.description) {
				self.centralManager.connect(peripheral, options: nil)
				self.startTrackingConnectedPeripheral(peripheral: peripheral)
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
	}

	///
	/// Peripheral callbacks
	///

	func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
		
		// Enumerate the discovered services.
		if let services = peripheral.services {
			for service in services {

				// Make sure this is a service that we're interested in.
				for (_, value) in self.serviceIdsToScanFor.enumerated() {
					if value == service.uuid {

						// Notify callbacks.
						for cb in self.serviceDiscoveryCallbacks {
							cb(service.uuid)
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

	func startScanning(serviceIdsToScanFor: Array<CBUUID>, peripheralCallbacks: Array<(String) -> Bool>, serviceCallbacks: Array<(CBUUID) -> Void>, valueUpdatedCallbacks: Array<(CBPeripheral, CBUUID, Data) -> Void>) {
		self.serviceIdsToScanFor = serviceIdsToScanFor
		self.peripheralDiscoveryCallbacks = peripheralCallbacks
		self.serviceDiscoveryCallbacks = serviceCallbacks
		self.valueUpdatedCallbacks = valueUpdatedCallbacks
		self.centralManager = CBCentralManager(delegate: self, queue: nil)
	}
	func stopScanning() {
		self.centralManager = nil
	}
}
