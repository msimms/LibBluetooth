//
//  LibBluetooth.swift
//  Created by Michael Simms on 3/28/23.
//

import Foundation
import CoreBluetooth

let scanner: BluetoothScanner = BluetoothScanner()
var serviceIdsToScanFor: Array<CBUUID> = []
var peripheralDiscoveredCallbacks: Array<(CBPeripheral, String) -> Bool> = [peripheralDiscovered]
var serviceCallbacks: Array<(CBPeripheral, CBUUID) -> Void> = [serviceDiscovered]
var valueUpdatedCallbacks: Array<ValueUpdatedCbType> = [valueUpdated]
var peripheralDisconnectedCallbacks: Array<(CBPeripheral) -> Void> = [peripheralDisconnected]

/// Called when a peripheral is discovered.
/// Returns true to indicate that we should connect to this peripheral and discover its services.
func peripheralDiscovered(peripheral: CBPeripheral, description: String) -> Bool {
	print("Discovered: " + description)
	return true
}

/// Called when a service is discovered.
func serviceDiscovered(peripheral: CBPeripheral, serviceId: CBUUID) {
}

/// Called when a sensor characteristic is updated.
func valueUpdated(peripheral: CBPeripheral, serviceId: CBUUID, value: Data) {
}

/// Called when a peripheral is disconnects.
func peripheralDisconnected(peripheral: CBPeripheral) {
}

@_cdecl("libbluetooth_addHrmToScanList")
func libbluetooth_addHrmToScanList() {
	serviceIdsToScanFor.append(CBUUID(data: BT_SERVICE_HEART_RATE))
}

@_cdecl("libbluetooth_addCyclingPowerToScanList")
func libbluetooth_addCyclingPowerToScanList() {
	serviceIdsToScanFor.append(CBUUID(data: BT_SERVICE_CYCLING_POWER))
}

@_cdecl("libbluetooth_addCyclingSpeedAndCadenceToScanList")
func libbluetooth_addCyclingSpeedAndCadenceToScanList() {
	serviceIdsToScanFor.append(CBUUID(data: BT_SERVICE_CYCLING_SPEED_AND_CADENCE))
}

@_cdecl("libbluetooth_addCyclingRadarToScanList")
func libbluetooth_addCyclingRadarToScanList() {
	serviceIdsToScanFor.append(CBUUID(data: CUSTOM_BT_SERVICE_VARIA_RADAR))
}

@_cdecl("libbluetooth_addFitnessMachineToScanList")
func libbluetooth_addFitnessMachineToScanList() {
	serviceIdsToScanFor.append(CBUUID(data: BT_SERVICE_FITNESS_MACHINE))
}

@_cdecl("libbluetooth_startScanningForServices")
func libbluetooth_startScanningForServices() {
	scanner.startScanningForServices(serviceIdsToScanFor: serviceIdsToScanFor,
									 peripheralDiscoveredCallbacks: peripheralDiscoveredCallbacks,
									 serviceCallbacks: serviceCallbacks,
									 valueUpdatedCallbacks: valueUpdatedCallbacks,
									 peripheralDisconnectedCallbacks: peripheralDisconnectedCallbacks)
}

@_cdecl("libbluetooth_stopScanning")
func libbluetooth_stopScanning() {
	scanner.stopScanning()
}
