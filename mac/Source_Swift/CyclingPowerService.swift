//
//  CyclingPowerService.swift
//  Created by Michael Simms on 8/18/22.
//

import Foundation

/// @brief Key names used with the JSON parser.
let KEY_NAME_CYCLING_POWER_WATTS = "Power"
let KEY_NAME_CYCLING_POWER_CRANK_REVS = "Crank Revs"
let KEY_NAME_CYCLING_POWER_LAST_CRANK_TIME = "Last Crank Time"

let ERROR_INAPPROPRIATE_CONNECTION_PARAMETER: UInt8 = 0x80

let FLAGS_PEDAL_POWER_BALANCE_PRESENT: UInt16 = 0x0001
let FLAGS_PEDAL_POWER_BALANCE_REFERENCE: UInt16 = 0x0002
let FLAGS_ACCUMULATED_TORQUE_PRESENT: UInt16 = 0x0004
let FLAGS_ACCUMULATED_TORQUE_SOURCE: UInt16 = 0x0008
let FLAGS_WHEEL_REVOLUTION_DATA_PRESENT: UInt16 = 0x0010
let FLAGS_CRANK_REVOLUTION_DATA_PRESENT: UInt16 = 0x0020
let FLAGS_EXTREME_FORCE_MAGNITUDES_PRESENT: UInt16 = 0x0040
let FLAGS_EXTREME_TORQUE_MAGNITUDES_PRESENT: UInt16 = 0x0080
let FLAGS_EXTREME_ANGLES_PRESENT: UInt16 = 0x0100
let FLAGS_TOP_DEAD_SPOT_ANGLE_PRESENT: UInt16 = 0x0200
let FLAGS_BOTTOM_DEAD_SPOT_ANGLE_PRESENT: UInt16 = 0x0400
let FLAGS_ACCUMULATED_ENERGY_PRESENT: UInt16 = 0x0800
let FLAGS_OFFSET_COMPENSATION_INDICATOR: UInt16 = 0x1000

enum CyclingPowerException: Error {
	case runtimeError(String)
}

struct CyclingPowerMeasurement {
	var flags: UInt16 = 0
	var power: UInt16 = 0
}

func decodeCyclingPowerReading(data: Data) throws -> UInt16 {
	if data.count < 4 {
		throw CyclingPowerException.runtimeError("Not enough data")
	}

	var pwr = CyclingPowerMeasurement()
	pwr.flags = ((UInt16)(data[0]) << 8) | (UInt16)(data[1])
	pwr.power = ((UInt16)(data[2]) << 8) | (UInt16)(data[3])
	return CFSwapInt16BigToHost(pwr.power)
}

func decodeCyclingPowerReadingAsDict(data: Data) throws -> Dictionary<String, UInt32> {
	if data.count < 4 {
		throw CyclingPowerException.runtimeError("Not enough data")
	}
	
	var result: Dictionary<String, UInt32> = [:]
	var reportBytesIndex = 0

	let flags = ((UInt16)(data[1]) << 8) | (UInt16)(data[0])
	reportBytesIndex += MemoryLayout<UInt16>.size

	let pwr = ((UInt16)(data[2]) << 8) | (UInt16)(data[3])
	reportBytesIndex += MemoryLayout<UInt16>.size
	result[KEY_NAME_CYCLING_POWER_WATTS] = UInt32(CFSwapInt16BigToHost(pwr))

	if flags & FLAGS_PEDAL_POWER_BALANCE_PRESENT != 0 {
		reportBytesIndex += MemoryLayout<UInt8>.size
	}
	if flags & FLAGS_ACCUMULATED_TORQUE_PRESENT != 0{
		reportBytesIndex += MemoryLayout<UInt16>.size
	}
	if flags & FLAGS_WHEEL_REVOLUTION_DATA_PRESENT != 0 {
		reportBytesIndex += MemoryLayout<UInt32>.size
		reportBytesIndex += MemoryLayout<UInt16>.size
	}
	if (flags & FLAGS_CRANK_REVOLUTION_DATA_PRESENT != 0) && (reportBytesIndex <= data.count - MemoryLayout<UInt16>.size - MemoryLayout<UInt16>.size) {
		let crankRevsBytes = ((UInt16)(data[reportBytesIndex]) << 8) | (UInt16)(data[reportBytesIndex + 1])
		result[KEY_NAME_CYCLING_POWER_CRANK_REVS] = UInt32(CFSwapInt16BigToHost(crankRevsBytes))
		reportBytesIndex += MemoryLayout<UInt16>.size

		let lastCrankTime = ((UInt16)(data[reportBytesIndex]) << 8) | (UInt16)(data[reportBytesIndex + 1])
		result[KEY_NAME_CYCLING_POWER_LAST_CRANK_TIME] = UInt32(CFSwapInt16BigToHost(lastCrankTime))
		reportBytesIndex += MemoryLayout<UInt16>.size
	}
		
	return result
}
