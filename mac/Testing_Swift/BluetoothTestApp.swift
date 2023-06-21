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
	@Published var currentCadenceRpm: UInt16 = 0
	@Published var currentWeight: Double = 0.0
	@Published var radarMeasurements: Array<RadarMeasurement> = []
	private var lastCrankCount: UInt16 = 0
	private var lastCrankCountTime: UInt64 = 0
	private var lastCadenceUpdateTimeMs: UInt64 = 0
	private var firstCadenceUpdate: Bool = true
	private var fitnessMachineState: Dictionary<String, UInt32> = [:]

	/// Called when a peripheral is discovered.
	/// Returns true to indicate that we should connect to this peripheral and discover its services.
	func peripheralDiscovered(peripheral: CBPeripheral, description: String) -> Bool {
		print("Discovered: " + description)
		return true
	}

	/// Called when a service is discovered.
	func serviceDiscovered(peripheral: CBPeripheral, serviceId: CBUUID) {
	}

	func calculateCadence(curTimeMs: UInt64, currentCrankCount: UInt16, currentCrankTime: UInt64) {
		let msSinceLastUpdate = curTimeMs - self.lastCadenceUpdateTimeMs
		var elapsedSecs: Double = 0.0

		if currentCrankTime >= self.lastCrankCountTime { // handle wrap-around
			elapsedSecs = Double(currentCrankTime - self.lastCrankCountTime) / 1024.0
		}
		else {
			let temp: UInt32 = 0x0000ffff + UInt32(currentCrankTime)
			elapsedSecs = Double(temp - UInt32(self.lastCrankCountTime)) / 1024.0
		}

		// Compute the cadence (zero on the first iteration).
		if self.firstCadenceUpdate {
			self.currentCadenceRpm = 0
		}
		else if elapsedSecs > 0.0 {
			let newCrankCount = currentCrankCount - self.lastCrankCount
			self.currentCadenceRpm = UInt16((Double(newCrankCount) / elapsedSecs) * 60.0)
		}

		// Handle cases where it has been a while since our last update (i.e. the crank is either not
		// turning or is turning very slowly).
		if msSinceLastUpdate >= 3000 {
			self.currentCadenceRpm = 0
		}

		self.lastCadenceUpdateTimeMs = curTimeMs
		self.firstCadenceUpdate = false
		self.lastCrankCount = currentCrankCount
		self.lastCrankCountTime = currentCrankTime
	}

	/// Called when a sensor characteristic is updated.
	func valueUpdated(peripheral: CBPeripheral, serviceId: CBUUID, value: Data) {
		do {
			if serviceId == CBUUID(data: BT_SERVICE_HEART_RATE) {
				print("Heart rate updated")
				self.currentHeartRateBpm = decodeHeartRateReading(data: value)
			}
			else if serviceId == CBUUID(data: BT_SERVICE_CYCLING_POWER) {
				print("Cycling power updated")
				self.currentPowerWatts = try decodeCyclingPowerReading(data: value)
			}
			else if serviceId == CBUUID(data: BT_SERVICE_CYCLING_SPEED_AND_CADENCE) {
				print("Cycling cadence updated")
				let reading = try decodeCyclingCadenceReading(data: value)
				let currentCrankCount = reading[KEY_NAME_WHEEL_CRANK_COUNT]
				let currentCrankTime = reading[KEY_NAME_WHEEL_CRANK_TIME]
				let timestamp = NSDate().timeIntervalSince1970
				self.calculateCadence(curTimeMs: UInt64(timestamp), currentCrankCount: UInt16(currentCrankCount!), currentCrankTime: UInt64(currentCrankTime!))
			}
			else if serviceId == CBUUID(data: BT_SERVICE_FITNESS_MACHINE) {
				print("Fitness machine data received")
				self.fitnessMachineState = try decodeFitnessMachineData(data: value, fitnessMachineState: self.fitnessMachineState)
				if let fitnessMachineType = self.fitnessMachineState[KEY_NAME_FITNESS_MACHINE_TYPE] {
					let tempFitnessMachineType: UInt16 = numericCast(fitnessMachineType)

					if tempFitnessMachineType & TREADMILL_SUPPORTED != 0 {
						print("Found a treadmill.")
					}
					if tempFitnessMachineType & CROSS_TRAINER_SUPPORTED != 0 {
						print("Found a cross trainer.")
					}
					if tempFitnessMachineType & STEP_CLIMBER_SUPPORTED != 0 {
						print("Found a step climber.")
					}
					if tempFitnessMachineType & STAIR_CLIMBER_SUPPORTED != 0 {
						print("Found a stair climber.")
					}
					if tempFitnessMachineType & ROWER_SUPPORTED != 0 {
						print("Found a rower.")
					}
					if tempFitnessMachineType & INDOOR_BIKE_SUPPORTED != 0 {
						print("Found an indoor bike.")
					}
				}
				if let fitnessMachineChars = self.fitnessMachineState[KEY_NAME_FITNESS_MACHINE_CHARACTERISTICS] {
					print("Characteristics: " + String(format:"%04X", fitnessMachineChars))
				}
			}
			else if serviceId == CBUUID(data: BT_SERVICE_WEIGHT) {
				print("Weight updated")
				self.currentWeight = decodeWeightReading(data: value)
			}
			else if serviceId == CBUUID(data: CUSTOM_BT_SERVICE_VARIA_RADAR) {
				print("Radar updated")
				self.radarMeasurements = decodeCyclingRadarReading(data: value)
			}
		} catch {
			print(error.localizedDescription)
		}
	}

	func startBluetoothScanning() -> BluetoothScanner {
		let scanner = BluetoothScanner()
		let interestingServices = [ CBUUID(data: BT_SERVICE_HEART_RATE),
									CBUUID(data: BT_SERVICE_CYCLING_POWER),
									CBUUID(data: BT_SERVICE_CYCLING_SPEED_AND_CADENCE),
									CBUUID(data: BT_SERVICE_WEIGHT),
									CBUUID(data: BT_SERVICE_FITNESS_MACHINE),
								    CBUUID(data: CUSTOM_BT_SERVICE_VARIA_RADAR) ]

		// Start scanning for the services that we are interested in.
		scanner.startScanningForServices(serviceIdsToScanFor: interestingServices,
										 peripheralDiscoveredCallbacks: [peripheralDiscovered],
										 serviceCallbacks: [serviceDiscovered],
										 valueUpdatedCallbacks: [valueUpdated],
										 peripheralDisconnectedCallbacks: [])
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
