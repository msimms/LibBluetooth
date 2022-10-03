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

func decodeCyclingCadenceReading(data: Data) -> Dictionary<String, UInt32> {
	var result : Dictionary<String, UInt32> = [:]

	var cscData = CscMeasurement()
	var revData = RevMeasurement()

	cscData.flags = data[0]
	cscData.cumulativeWheelRevs = (UInt32)(data[1] << 24) | (UInt32)(data[2] << 16) | (UInt32)(data[3] << 8) | (UInt32)(data[4])
	cscData.lastWheelEventTime = (UInt16)(data[5] << 8) | (UInt16)(data[6])
	cscData.cumulativeCrankRevs = (UInt16)(data[7] << 8) | (UInt16)(data[8])
	cscData.lastCrankEventTime = (UInt16)(data[9] << 8) | (UInt16)(data[10])

	revData.flags = data[0]
	revData.cumulativeCrankRevs = (UInt16)(data[1] << 8) | (UInt16)(data[2])
	revData.lastCrankEventTime = (UInt16)(data[3] << 8) | (UInt16)(data[4])

	if (cscData.flags & WHEEL_REVOLUTION_DATA_PRESENT != 0)
	{
		result[KEY_NAME_WHEEL_REV_COUNT] = UInt32(CFSwapInt32LittleToHost(cscData.cumulativeWheelRevs))
	}
	if (cscData.flags & CRANK_REVOLUTION_DATA_PRESENT != 0)
	{
		if data.count > 5 {
			result[KEY_NAME_WHEEL_CRANK_COUNT] = UInt32(CFSwapInt16LittleToHost(cscData.cumulativeCrankRevs))
			result[KEY_NAME_WHEEL_CRANK_TIME] = UInt32(CFSwapInt16LittleToHost(cscData.lastCrankEventTime))
		}
		else {
			result[KEY_NAME_WHEEL_CRANK_COUNT] = UInt32(CFSwapInt16LittleToHost(revData.cumulativeCrankRevs))
			result[KEY_NAME_WHEEL_CRANK_TIME] = UInt32(CFSwapInt16LittleToHost(revData.lastCrankEventTime))
		}
	}

	return result
}
