//
//  HydrometerService.swift
//  Created by Michael Simms on 8/18/22.
//

import Foundation

struct HydrometerMeasurement {
	var temperature: UInt16 = 0
	var gravity: UInt16 = 0
}

func decodeHydrometerReading(data: Data) -> ( UInt16, UInt16 ) {
	let measure = HydrometerMeasurement()
	return ( CFSwapInt16LittleToHost(measure.temperature), CFSwapInt16LittleToHost(measure.gravity) )
}
