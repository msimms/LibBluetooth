//
//  HeartRateService.swift
//  Created by Michael Simms on 5/5/22.
//

import Foundation

let ERROR_HEART_RATE_CONTROL_POINT_NO_SUPPORTED: UInt8 = 0x80

let FLAGS_HEART_RATE_VALUE: UInt8 = 0x01 // 0 means 8 bit value, 1 means 16 bit value
let FLAGS_SENSOR_CONTACT_STATUS_FEATURE_VALUE: UInt8 = 0x02 // indicate whether or not skin contact is supported
let FLAGS_SENSOR_CONTACT_STATUS_DETECTED_VALUE: UInt8 = 0x03 // indicate whether or not skin contact is detected
let FLAGS_ENERGY_EXPENDED_STATUS_VALUE: UInt8 = 0x04 // indicates whether or not the Energy Expended field is present, providing energy in kilojoules
let FLAGS_RR_VALUE: UInt8 = 0x08 // indicates whether or not the RR field is present

struct HeartRateMeasurement {
	var flags: UInt8 = 0
	var value8: UInt8 = 0
	var value16: UInt16 = 0
	var energyExpended: UInt16 = 0
	var rrInterval: UInt16 = 0
}

func decodeHeartRateReading(data: Data) -> UInt16 {
	if (data.count < 1) {
		return 0
	}

	var hrm = HeartRateMeasurement()
	hrm.flags = data[0];
	
	if data.count < 2 {
		return 0
	}

	if (hrm.flags & FLAGS_HEART_RATE_VALUE) == 0 {
		hrm.value8 = data[1];
		return UInt16(hrm.value8)
	}

	if data.count < 3 {
		return 0
	}

	hrm.value16 = (UInt16(data[1]) >> 8) | (UInt16(data[2]))
	return CFSwapInt16LittleToHost(hrm.value16)
}
