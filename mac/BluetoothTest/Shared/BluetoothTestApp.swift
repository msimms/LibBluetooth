//
//  BluetoothTestApp.swift
//  Shared
//
//  Created by Michael Simms on 5/3/22.
//

import SwiftUI
import CoreBluetooth

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
	print(decodeHeartRateReading(data: value))
}

func startBluetoothScanning() -> BluetoothScanner {
	let scanner = BluetoothScanner()
	let interestingServices = [CBUUID(data: BT_SERVICE_HEART_RATE)]

	// Start scanning for the services that we are interested in.
	scanner.startScanning(serviceIdsToScanFor: interestingServices, peripheralCallbacks: [peripheralDiscovered], serviceCallbacks: [serviceDiscovered], valueUpdatedCallbacks: [valueUpdated])
	return scanner
}

@main
struct BluetoothTestApp: App {
	let scanner = startBluetoothScanning()

	var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
