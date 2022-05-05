//
//  BluetoothScanner.swift
//  BluetoothTest
//
//  Created by Michael Simms on 5/3/22.
//

import Foundation
import CoreBluetooth

class BluetoothScanner: NSObject, CBPeripheralDelegate, CBCentralManagerDelegate, ObservableObject {
	
	@Published var connectedPeripherals: Array<CBPeripheral> = []

	private var centralManager: CBCentralManager!
	private var serviceIdsToScanFor: Array<CBUUID> = []
	private var peripheralDiscoveryCallbacks: Array<(String) -> Bool> = []
	private var serviceDiscoveryCallbacks: Array<() -> Bool> = []
	private var valueUpdatedCallbacks: Array<(CBPeripheral, Data) -> Void> = []

	func startTrackingConnectedPeripheral(peripheral: CBPeripheral) {
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
	func stopTrackingConnectedPeripheral(peripheral: CBPeripheral) {
		for (index, value) in self.connectedPeripherals.enumerated() {
			if value == peripheral {
				self.connectedPeripherals.remove(at: index)
				break
			}
		}
	}
	func isTrackedPeripheral(peripheral: CBPeripheral) -> Bool {
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
		if let services = peripheral.services {
			for service in services {
				for (_, value) in self.serviceIdsToScanFor.enumerated() {
					if value == service.uuid {
						peripheral.discoverCharacteristics(nil, for: service)
						return
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
				cb(peripheral, characteristic.value!)
			}
		}
	}
	func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
	}

	func startScanning(serviceIdsToScanFor: Array<CBUUID>, peripheralCallbacks: Array<(String) -> Bool>, serviceCallbacks: Array<() -> Bool>, valueUpdatedCallbacks: Array<(CBPeripheral, Data) -> Void>) {
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
