//
//  BluetoothPeripheral.swift
//  Created by Michael Simms on 6/6/24.
//

import Foundation
import CoreBluetooth

class HeartRatePeripheralManager: NSObject, CBPeripheralManagerDelegate {

	var peripheralManager: CBPeripheralManager!
	let heartRateMeasurementCharacteristicUUID = CBUUID(string: "2A37")
	var heartRateMeasurementCharacteristic: CBMutableCharacteristic!

	override init() {
		super.init()
		
		self.peripheralManager = CBPeripheralManager()
		self.peripheralManager.delegate = self
	}

	/// @brief Peripheral manager delegate methods
	func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
		if peripheral.state == .poweredOn {

			// Create the heart rate measurement characteristic.
			self.heartRateMeasurementCharacteristic = CBMutableCharacteristic(
				type: self.heartRateMeasurementCharacteristicUUID,
				properties: [.notify, .read],
				value: nil,
				permissions: [.readable]
			)

			// Create the heart rate service.
			let heartRateService = CBMutableService(type: CBUUID(data: BT_SERVICE_HEART_RATE), primary: true)

			// Add the characteristic to the service.
			heartRateService.characteristics = [heartRateMeasurementCharacteristic]

			// Add the service to the peripheral manager.
			self.peripheralManager.add(heartRateService)

			// Start advertising the service.
			self.peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [BT_SERVICE_HEART_RATE]])
		}
	}
	
	func start() {
		self.peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [BT_SERVICE_HEART_RATE]])
	}
	
	func stop() {
		self.peripheralManager.stopAdvertising()
	}

	/// @brief Handle new central subscriptions to the characteristic
	func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
	}
	
	/// @brief Handle central unsubscriptions from the characteristic
	func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
	}
	
	/// @brief Sends the heart rate data.
	func sendHeartRate(heartRate: UInt16) {

		// Encode the heart rate measurement data.
		let heartRateData = encodeHeartRateReading(bpm: heartRate)
		
		// Update the characteristic value.
		self.peripheralManager.updateValue(heartRateData, for: self.heartRateMeasurementCharacteristic, onSubscribedCentrals: nil)
	}
}
