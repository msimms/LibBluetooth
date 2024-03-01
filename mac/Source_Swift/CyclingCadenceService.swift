//
//  CyclingCadenceService.swift
//  Created by Michael Simms on 10/3/22.
//

import Foundation

let KEY_NAME_WHEEL_REV_COUNT = "Wheel Rev Count"
let KEY_NAME_WHEEL_CRANK_COUNT = "Crank Count"
let KEY_NAME_WHEEL_CRANK_TIME = "Crank Time"

let ERROR_PROCEDURE_ALREADY_IN_PROGRESS: UInt8 = 0x80
let ERROR_CLIENT_CHARACTERISTIC_CONFIG_DESC_IMPROPERLY_CONFIGURED: UInt8 = 0x81

let WHEEL_REVOLUTION_DATA_PRESENT: UInt8 = 0x01
let CRANK_REVOLUTION_DATA_PRESENT: UInt8 = 0x02

enum CyclingCadenceException: Error {
	case runtimeError(String)
}

struct CscMeasurement {
	var flags: UInt8 = 0
	var cumulativeWheelRevs: UInt32 = 0
	var lastWheelEventTime: UInt16 = 0
	var cumulativeCrankRevs: UInt16 = 0
	var lastCrankEventTime: UInt16 = 0
}

struct RevMeasurement {
	var flags: UInt8 = 0
	var cumulativeCrankRevs: UInt16 = 0
	var lastCrankEventTime: UInt16 = 0
}

func decodeCyclingCadenceReading(data: Data) throws -> Dictionary<String, UInt32> {
	if data.count < 5 {
		throw CyclingCadenceException.runtimeError("Not enough data")
	}

	var result: Dictionary<String, UInt32> = [:]
	var index = 0

	var cscData = CscMeasurement()
	var revData = RevMeasurement()

	cscData.flags = data[index]
	revData.flags = data[index]
	index += 1

	if cscData.flags & WHEEL_REVOLUTION_DATA_PRESENT != 0 {
		cscData.cumulativeWheelRevs = ((UInt32)(data[index]) << 24) | ((UInt32)(data[index + 1]) << 16) | ((UInt32)(data[index + 2]) << 8) | (UInt32)(data[index + 3])
		cscData.lastWheelEventTime = ((UInt16)(data[index + 4]) << 8) | (UInt16)(data[index + 5])
		result[KEY_NAME_WHEEL_REV_COUNT] = UInt32(CFSwapInt32BigToHost(cscData.cumulativeWheelRevs))
		index += 6
	}
	if cscData.flags & CRANK_REVOLUTION_DATA_PRESENT != 0 {
		cscData.cumulativeCrankRevs = ((UInt16)(data[index]) << 8) | (UInt16)(data[index + 1])
		cscData.lastCrankEventTime = ((UInt16)(data[index + 2]) << 8) | (UInt16)(data[index + 3])
		result[KEY_NAME_WHEEL_CRANK_COUNT] = UInt32(CFSwapInt16BigToHost(cscData.cumulativeCrankRevs))
		result[KEY_NAME_WHEEL_CRANK_TIME] = UInt32(CFSwapInt16BigToHost(cscData.lastCrankEventTime))
		index += 4
	}

	return result
}
