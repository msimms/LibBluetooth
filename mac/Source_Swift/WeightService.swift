//
//  WeightService.swift
//  Created by Michael Simms on 6/17/23.
//

import Foundation

struct TimeDateReading {
	var year: UInt16 = 0
	var month: UInt8 = 0
	var day: UInt8 = 0
	var hour: UInt8 = 0
	var minute: UInt8 = 0
	var second: UInt8 = 0
}

struct WeightMeasurement {
	var flags: UInt8 = 0
	var weightSI: UInt16 = 0       // Unit is in kilograms with a resolution of 0.005
	var weightImperial: UInt16 = 0 // Unit is in pounds with a resolution of 0.01
	var userId: UInt8 = 0
	var timeDate: TimeDateReading
	var bmi: UInt16 = 0            // Unit is unitless with a resolution of 0.1
	var heightSI: UInt16 = 0       // Unit is in meters with a resolution of 0.001
	var heightImperial: UInt16 = 0 // Unit is in inches with a resolution of 0.1,
}

enum WeightException: Error {
	case runtimeError(String)
}

func decodeWeightReading(data: Data) -> Double {
	let weightKg: Double = (Double)(CFSwapInt16LittleToHost(read16(data: data))) / 200.0
	return weightKg
}
