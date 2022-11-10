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
	
	// For debugging
/*	var packetStr = ""
	for i in 0...data.count - 1 {
		packetStr += String(format: "%02X", data[i])
	}
	print(packetStr) */
	
	// We need enough bytes to cover the structure and two bytes for the manufacturer ID.
	let bytesNeeded = MemoryLayout<HydrometerMeasurement>.size + 2
	if data.count < bytesNeeded {
		throw HydrometerException.runtimeError("Not enough data")
	}
	
	measure.beacon = (UInt16)(data[2] << 8) | (UInt16)(data[3])
	measure.type = data[4]
	measure.len = data[5]
	for i in 0...15 {
		measure.serviceId[i] = data[i + 6]
	}
	measure.temperature = (UInt16)(data[22] << 8) | (UInt16)(data[23])
	measure.gravity = (UInt16)(data[24] << 8) | (UInt16)(data[25])
	
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
