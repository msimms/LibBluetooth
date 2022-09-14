//
//  HydrometerService.swift
//  Created by Michael Simms on 8/18/22.
//

import Foundation

struct HydrometerMeasurement {
	var mysteryBytes: UInt16 = 0
	var serviceId: [UInt8] = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
	var temperature: UInt16 = 0
	var gravity: UInt16 = 0
}

func decodeHydrometerReading(data: Data) -> ( UInt16, UInt16 ) {
	var measure = HydrometerMeasurement()
	measure.mysteryBytes = (UInt16)(data[0] << 8) | (UInt16)(data[1])
	for i in 0...15 {
		measure.serviceId[i] = data[i + 2]
	}
	measure.temperature = (UInt16)(data[17] << 8) | (UInt16)(data[18])
	measure.gravity = (UInt16)(data[19] << 8) | (UInt16)(data[20])
	return ( CFSwapInt16LittleToHost(measure.temperature), CFSwapInt16LittleToHost(measure.gravity) )
}
