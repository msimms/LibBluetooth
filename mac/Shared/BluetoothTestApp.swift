//
//  BluetoothTestApp.swift
//  Created by Michael Simms on 5/3/22.
//

import SwiftUI
import CoreBluetooth

class AppState : ObservableObject {

	static let shared = AppState()
	@Published var currentHeartRateBpm: UInt16 = 0
	@Published var currentPowerWatts: UInt16 = 0

	/// Called when a peripheral is discovered.
	/// Returns true to indicate that we should connect to this peripheral and discover its services.
	func peripheralDiscovered(description: String) -> Bool {
		return true
	}

	/// Called when a service is discovered.
	func serviceDiscovered(serviceId: CBUUID) {
	}

	/// Called when a sensor characteristic is updated.
	func valueUpdated(peripheral: CBPeripheral, serviceId: CBUUID, value: Data) {
		currentHeartRateBpm = decodeHeartRateReading(data: value)
		print(currentHeartRateBpm)
	}

	func startBluetoothScanning() -> BluetoothScanner {
		let scanner = BluetoothScanner()
		let interestingServices = [CBUUID(data: BT_SERVICE_HEART_RATE)]

		// Start scanning for the services that we are interested in.
		scanner.startScanning(serviceIdsToScanFor: interestingServices, peripheralCallbacks: [peripheralDiscovered], serviceCallbacks: [serviceDiscovered], valueUpdatedCallbacks: [valueUpdated])
		return scanner
	}
}

@main
struct BluetoothTestApp: App {
	let state = AppState.shared.startBluetoothScanning()

	var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
