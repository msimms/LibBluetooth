//
//  HydrometerService.swift
//  Created by Michael Simms on 8/18/22.
//

import Foundation

let CUSTOM_BT_SERVICE_TILT_HYDROMETER1 = Data([0xa4, 0x95, 0xbb, 0x10, 0xc5, 0xb1, 0x4b, 0x44, 0xb5, 0x12, 0x13, 0x70, 0xf0, 0x2d, 0x74, 0xde]) // Tilt hydrometer
let CUSTOM_BT_SERVICE_TILT_HYDROMETER2 = Data([0xa4, 0x95, 0xbb, 0x20, 0xc5, 0xb1, 0x4b, 0x44, 0xb5, 0x12, 0x13, 0x70, 0xf0, 0x2d, 0x74, 0xde]) // Tilt hydrometer
let CUSTOM_BT_SERVICE_TILT_HYDROMETER3 = Data([0xa4, 0x95, 0xbb, 0x30, 0xc5, 0xb1, 0x4b, 0x44, 0xb5, 0x12, 0x13, 0x70, 0xf0, 0x2d, 0x74, 0xde]) // Tilt hydrometer
let CUSTOM_BT_SERVICE_TILT_HYDROMETER4 = Data([0xa4, 0x95, 0xbb, 0x40, 0xc5, 0xb1, 0x4b, 0x44, 0xb5, 0x12, 0x13, 0x70, 0xf0, 0x2d, 0x74, 0xde]) // Tilt hydrometer
let CUSTOM_BT_SERVICE_TILT_HYDROMETER5 = Data([0xa4, 0x95, 0xbb, 0x50, 0xc5, 0xb1, 0x4b, 0x44, 0xb5, 0x12, 0x13, 0x70, 0xf0, 0x2d, 0x74, 0xde]) // Tilt hydrometer
let CUSTOM_BT_SERVICE_TILT_HYDROMETER6 = Data([0xa4, 0x95, 0xbb, 0x60, 0xc5, 0xb1, 0x4b, 0x44, 0xb5, 0x12, 0x13, 0x70, 0xf0, 0x2d, 0x74, 0xde]) // Tilt hydrometer
let CUSTOM_BT_SERVICE_TILT_HYDROMETER7 = Data([0xa4, 0x95, 0xbb, 0x70, 0xc5, 0xb1, 0x4b, 0x44, 0xb5, 0x12, 0x13, 0x70, 0xf0, 0x2d, 0x74, 0xde]) // Tilt hydrometer
let CUSTOM_BT_SERVICE_TILT_HYDROMETER8 = Data([0xa4, 0x95, 0xbb, 0x80, 0xc5, 0xb1, 0x4b, 0x44, 0xb5, 0x12, 0x13, 0x70, 0xf0, 0x2d, 0x74, 0xde]) // Tilt hydrometer

struct HydrometerMeasurement {
	var beacon: UInt16 = 0
	var type: UInt8 = 0
	var len: UInt8 = 0
	var serviceId: [UInt8] = [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ]
	var temperature: UInt16 = 0
	var gravity: UInt16 = 0
}

enum HydrometerException: Error {
	case runtimeError(String)
}

func serviceIdCompare(serviceId: [UInt8], tiltId: Data) -> Bool {
	for i in 0...15 {
		if serviceId[i] != tiltId[i] {
			return false
		}
	}
	return true
}

func decodeHydrometerReading(data: Data) throws -> HydrometerMeasurement {
	var measure = HydrometerMeasurement()
	
	if data.count < MemoryLayout.size(ofValue: measure) {
		throw HydrometerException.runtimeError("Not enough data")
	}
	
	measure.beacon = (UInt16)(data[0] << 8) | (UInt16)(data[1])
	measure.type = data[2]
	measure.len = data[3]
	for i in 0...15 {
		measure.serviceId[i] = data[i + 5]
	}
	measure.temperature = (UInt16)(data[19] << 8) | (UInt16)(data[20])
	measure.gravity = (UInt16)(data[21] << 8) | (UInt16)(data[22])
	
	if (!(serviceIdCompare(serviceId: measure.serviceId, tiltId: CUSTOM_BT_SERVICE_TILT_HYDROMETER1) ||
		  serviceIdCompare(serviceId: measure.serviceId, tiltId: CUSTOM_BT_SERVICE_TILT_HYDROMETER2) ||
		  serviceIdCompare(serviceId: measure.serviceId, tiltId: CUSTOM_BT_SERVICE_TILT_HYDROMETER3) ||
		  serviceIdCompare(serviceId: measure.serviceId, tiltId: CUSTOM_BT_SERVICE_TILT_HYDROMETER4) ||
		  serviceIdCompare(serviceId: measure.serviceId, tiltId: CUSTOM_BT_SERVICE_TILT_HYDROMETER5) ||
		  serviceIdCompare(serviceId: measure.serviceId, tiltId: CUSTOM_BT_SERVICE_TILT_HYDROMETER6) ||
		  serviceIdCompare(serviceId: measure.serviceId, tiltId: CUSTOM_BT_SERVICE_TILT_HYDROMETER7) ||
		  serviceIdCompare(serviceId: measure.serviceId, tiltId: CUSTOM_BT_SERVICE_TILT_HYDROMETER8))) {
		throw HydrometerException.runtimeError("Not a Tilt hydrometer")
	}
	
	return measure
}
