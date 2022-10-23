//
//  CyclingPowerService.swift
//  Created by Michael Simms on 8/18/22.
//

import Foundation

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
	pwr.flags = (UInt16)(data[0] << 8) | (UInt16)(data[1])
	pwr.power = (UInt16)(data[2] << 8) | (UInt16)(data[3])
	return CFSwapInt16LittleToHost(pwr.power)
}
