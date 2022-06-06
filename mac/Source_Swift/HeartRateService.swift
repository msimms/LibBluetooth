//
//  HeartRateService.swift
//  Created by Michael Simms on 5/5/22.
//

import Foundation

let ERROR_HEART_RATE_CONTROL_POINT_NO_SUPPORTED: UInt8 = 0x80
let FLAGS_HEART_RATE_VALUE: UInt8 = 0x01
let FLAGS_SENSOR_CONTACT_STATUS_VALUE: UInt8 = 0x02
let FLAGS_ENERGY_EXPENDED_STATUS_VALUE: UInt8 = 0x04
let FLAGS_RR_VALUE: UInt8 = 0x08

struct HeartRateMeasurement {
	var flags: UInt8 = 0
	var value8: UInt8 = 0
	var value16: UInt16 = 0
	var energyExpended: UInt16 = 0
	var rrInterval: UInt16 = 0
}

func decodeHeartRateReading(data: Data) -> UInt16 {
	var hrm = HeartRateMeasurement()
	hrm.flags = data[0];
	hrm.value8 = data[1];
	hrm.value16 = (UInt16(data[1]) >> 8) | (UInt16(data[2]));

	if ((data[0] & FLAGS_HEART_RATE_VALUE) == 0) {
		return UInt16(hrm.value8)
	}
	return CFSwapInt16LittleToHost(hrm.value16)
}
