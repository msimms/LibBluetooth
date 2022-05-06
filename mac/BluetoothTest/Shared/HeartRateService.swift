//
//  HeartRateService.swift
//  BluetoothTest
//
//  Created by Michael Simms on 5/5/22.
//

import Foundation

let ERROR_HEART_RATE_CONTROL_POINT_NO_SUPPORTED: UInt8 = 0x80
let FLAGS_HEART_RATE_VALUE: UInt8 = 0x01
let FLAGS_SENSOR_CONTACT_STATUS_VALUE: UInt8 = 0x02
let FLAGS_ENERGY_EXPENDED_STATUS_VALUE: UInt8 = 0x04
let FLAGS_RR_VALUE: UInt8 = 0x08

struct HeartRateMeasurement {
	let flags: UInt8 = 0
	let value8: UInt8 = 0
	let value16: UInt16 = 0
	let energyExpended: UInt16 = 0
	let rrInterval: UInt16 = 0
}

func decodeHeartRateReading(data: Data) -> UInt16 {
	data.withUnsafeBytes { (rawBytes: UnsafePointer<UInt8>!) -> () in
	}

	if ((data[0] & FLAGS_HEART_RATE_VALUE) == 0) {
		return UInt16(data[1])
	}
	else {
		//return CFSwapInt16LittleToHost(reportData.value16)
	}
	return 0
}
