//
//  CyclingRadarService.swift
//  Created by Michael Simms on 10/20/22.
//

import Foundation

struct RadarMeasurement : Identifiable, Hashable {
	var id: UInt8 = 0
	var threatMeters: UInt8 = 0
	var threatLevel: UInt8 = 0
	
	/// Hashable overrides
	func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
	}
	
	/// Equatable overrides
	static func == (lhs: RadarMeasurement, rhs: RadarMeasurement) -> Bool {
		return lhs.id == rhs.id
	}
}

func decodeCyclingRadarReading(data: Data) -> Array<RadarMeasurement> {
	var result : Array<RadarMeasurement> = []
	let threatCount = data[0]

	if threatCount > 0 {
		var offset: Int = 1
		var threatIndex: Int = 0
		let threatSize = MemoryLayout<RadarMeasurement>.size
		
		while threatIndex < (threatCount - 1) && offset <= (data.count - threatSize) {
			var measurement: RadarMeasurement  = RadarMeasurement()
			
			measurement.id = data[offset]
			offset += 1
			measurement.threatMeters = data[offset]
			offset += 1
			measurement.threatLevel = data[offset]
			offset += 1
			
			result.append(measurement)
			threatIndex += 1
		}
	}
	return result
}
