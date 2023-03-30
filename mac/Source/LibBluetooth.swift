//
//  LibBluetooth.swift
//  Created by Michael Simms on 3/28/23.
//

import Foundation
import CoreBluetooth

let scanner: BluetoothScanner = BluetoothScanner()
var serviceIdsToScanFor: Array<CBUUID> = []

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
	let peripheralCallbacks: Array<(CBPeripheral, String) -> Bool> = []
	let serviceCallbacks: Array<(CBPeripheral, CBUUID) -> Void> = []
	let valueUpdatedCallbacks: Array<(CBPeripheral, CBUUID, Data) -> Void> = []
	let peripheralDisconnectedCallbacks: Array<(CBPeripheral) -> Void> = []

	scanner.startScanningForServices(serviceIdsToScanFor: serviceIdsToScanFor, peripheralCallbacks: peripheralCallbacks, serviceCallbacks: serviceCallbacks, valueUpdatedCallbacks: valueUpdatedCallbacks, peripheralDisconnectedCallbacks: peripheralDisconnectedCallbacks)
}

@_cdecl("libbluetooth_stopScanning")
func libbluetooth_stopScanning() {
	scanner.stopScanning()
}
