//
//  BluetoothTestApp.swift
//  Shared
//
//  Created by Michael Simms on 5/3/22.
//

import SwiftUI
import CoreBluetooth

func peripheralDiscovered(description: String) -> Bool {
	return true
}

func serviceDiscovered() -> Bool {
	return true
}

func valueUpdated(peripheral: CBPeripheral, value: Data) {
	print(value)
}

func startBluetoothScanning() -> BluetoothScanner {
	let scanner = BluetoothScanner()
	let interestingServices = [CBUUID(data: BT_SERVICE_HEART_RATE)]

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
