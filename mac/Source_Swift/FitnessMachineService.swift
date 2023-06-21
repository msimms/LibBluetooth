//
//  FitnessMachineService.swift
//  Created by Michael Simms on 2/4/23.
//

import Foundation

/// @brief Key names used with the JSON parser.
let KEY_NAME_FITNESS_MACHINE_FLAGS = "Fitness Machine Flags"
let KEY_NAME_FITNESS_MACHINE_TYPE = "Fitness Machine Type"
let KEY_NAME_FITNESS_MACHINE_CHARACTERISTICS = "Fitness Machine Characteristics"
let KEY_NAME_FITNESS_MACHINE_AVERAGE_SPEED = "Average Speed"
let KEY_NAME_FITNESS_MACHINE_CADENCE = "Cadence"
let KEY_NAME_FITNESS_MACHINE_TOTAL_DISTANCE = "Total Distance"
let KEY_NAME_FITNESS_MACHINE_INCLINATION = "Inclination"
let KEY_NAME_FITNESS_MACHINE_PACE = "Pace"
let KEY_NAME_FITNESS_MACHINE_RESISTANCE = "Resistance"

// Fitness Machine Types
let TREADMILL_SUPPORTED: UInt16 = 0x01
let CROSS_TRAINER_SUPPORTED: UInt16 = 0x02
let STEP_CLIMBER_SUPPORTED: UInt16 = 0x04
let STAIR_CLIMBER_SUPPORTED: UInt16 = 0x08
let ROWER_SUPPORTED: UInt16 = 0x10
let INDOOR_BIKE_SUPPORTED: UInt16 = 0x20

// Fitness Machine Features Field (4.3.1.1)
let AVERAGE_SPEED_SUPPORTED: UInt16 = 0x0001
let CADENCE_SUPPORTED: UInt16 = 0x0002
let TOTAL_DISTANCE_SUPPORTED: UInt16 = 0x0004
let INCLINATION_SUPPORTED: UInt16 = 0x0008
let ELEVATION_GAIN_SUPPORTED: UInt16 = 0x0010
let PACE_SUPPORTED: UInt16 = 0x0020
let STEP_COUNT_SUPPORTED: UInt16 = 0x0040
let RESISTANCE_LEVEL_SUPPORTED: UInt16 = 0x0080
let EXPENDED_ENERGY_SUPPORTED: UInt16 = 0x0100
let HEART_RATE_MEASUREMENT_SUPPORTED: UInt16 = 0x0200
let METABOLIC_EQUIVALENT_SUPPORTED: UInt16 = 0x0400
let ELAPSED_TIME_SUPPORTED: UInt16 = 0x0800
let REMAINING_TIME_SUPPORTED: UInt16 = 0x1000
let POWER_MEASUREMENT_SUPPORTED: UInt16 = 0x2000
let FORCE_ON_BELT_AND_POWER_OUTPUT_SUPPORTED: UInt16 = 0x4000
let USER_DATA_RETENTION_SUPPORTED: UInt16 = 0x8000

// Target Setting Features Field (4.3.1.2)
let SPEED_TARGET_SETTING_SUPPORTED: UInt16 = 0x0001
let INCLINATION_TARGET_SETTING_SUPPORTED: UInt16 = 0x0002
let RESISTANCE_TARGET_SETTING_SUPPORTED: UInt16 = 0x0004
let POWER_TARGET_SETTING_SUPPORTED: UInt16 = 0x0008
let HEART_RATE_TARGET_SETTING_SUPPORTED: UInt16 = 0x0010
let TARGETED_EXPENDED_ENERGY_CONFIGURATION_SUPPORTED: UInt16 = 0x0020
let TARGETED_STEP_NUMBER_CONFIGURATION_SUPPORTED: UInt16 = 0x0040
let TARGETED_STRIDE_NUMBER_CONFIGURATION_SUPPORTED: UInt16 = 0x0080
let TARGETED_DISTANCE_CONFIGURATION_SUPPORTED: UInt16 = 0x0080
let TARGETED_TRAINING_TIME_CONFIGURATION_SUPPORTED: UInt16 = 0x0100
let TARGETED_TIME_IN_TWO_HEART_RATE_ZONES_CONFIGURATION_SUPPORTED: UInt16 = 0x0200
let TARGETED_TIME_IN_THREE_HEART_RATE_ZONES_CONFIGURATION_SUPPORTED: UInt16 = 0x0400
let TARGETED_TIME_IN_FIVE_HEART_RATE_ZONES_CONFIGURATION_SUPPORTED: UInt16 = 0x0800
let INDOOR_BIKE_SIMULATION_PARAMETERS_SUPPORTED: UInt16 = 0x1000
let WHEEL_CIRCUMFERENCE_CONFIGURATION_SUPPORTED: UInt16 = 0x2000
let SPIN_DOWN_CONTROL_SUPPORTED: UInt16 = 0x4000
let TARGETED_CADENCE_CONFIGURATION_SUPPORTED: UInt16 = 0x8000

struct ServiceDataADType {
	var serviceDataADType: UInt8 = 0
	var fitnessMachineService: UInt16 = 0
	var flags: UInt8 = 0
	var fitnessMachineType: UInt16 = 0
}

enum FitnessMachineException: Error {
	case runtimeError(String)
}

func decodeFitnessMachineService(data: Data) throws -> Dictionary<String, UInt32> {
	var result: Dictionary<String, UInt32> = [:]

	if data.count < MemoryLayout<ServiceDataADType>.size {
		throw FitnessMachineException.runtimeError("Not enough data")
	}

	var serviceDataAD: ServiceDataADType = ServiceDataADType()
	serviceDataAD.serviceDataADType = data[0]
	serviceDataAD.fitnessMachineService = CFSwapInt16LittleToHost(read16(data: data.subdata(in: Range(1...2))))
	serviceDataAD.flags = data[3]
	serviceDataAD.fitnessMachineType = CFSwapInt16LittleToHost(read16(data: data.subdata(in: Range(4...5))))

	result[KEY_NAME_FITNESS_MACHINE_FLAGS] = UInt32(serviceDataAD.flags)
	result[KEY_NAME_FITNESS_MACHINE_TYPE] = UInt32(serviceDataAD.fitnessMachineType)

	return result
}

func decodeFitnessMachineCharacteristics(data: Data, fitnessMachineState: Dictionary<String, UInt32>) throws -> Dictionary<String, UInt32> {
	if data.count < 2 {
		throw FitnessMachineException.runtimeError("Not enough data")
	}

	var newFitnessMachineState = fitnessMachineState
	let fitnessMachineChars = CFSwapInt16LittleToHost(read16(data: data))
	newFitnessMachineState[KEY_NAME_FITNESS_MACHINE_CHARACTERISTICS] = UInt32(fitnessMachineChars)
	return newFitnessMachineState
}

func decodeTreadmillCharacteristics(data: Data, fitnessMachineState: Dictionary<String, UInt32>) throws -> Dictionary<String, UInt32> {
	return fitnessMachineState
}

func decodeCrossTrainerCharacteristics(data: Data, fitnessMachineState: Dictionary<String, UInt32>) throws -> Dictionary<String, UInt32> {
	return fitnessMachineState
}

func decodeStepClimberCharacteristics(data: Data, fitnessMachineState: Dictionary<String, UInt32>) throws -> Dictionary<String, UInt32> {
	return fitnessMachineState
}

func decodeStairClimberCharacteristics(data: Data, fitnessMachineState: Dictionary<String, UInt32>) throws -> Dictionary<String, UInt32> {
	return fitnessMachineState
}

func decodeRowerCharacteristics(data: Data, fitnessMachineState: Dictionary<String, UInt32>) throws -> Dictionary<String, UInt32> {
	return fitnessMachineState
}

func decodeIndoorBikeCharacteristics(data: Data, fitnessMachineState: Dictionary<String, UInt32>) throws -> Dictionary<String, UInt32> {
	var newFitnessMachineState = fitnessMachineState

	if let fitnessMachineChars = fitnessMachineState[KEY_NAME_FITNESS_MACHINE_CHARACTERISTICS] {
		let chars: UInt16 = numericCast(fitnessMachineChars)
		var offset = 0

		if chars & AVERAGE_SPEED_SUPPORTED != 0 {
			print("Average speed supported: " + String(data[offset]))
			newFitnessMachineState[KEY_NAME_FITNESS_MACHINE_AVERAGE_SPEED] = UInt32(data[offset])
			offset += 1
		}
		if chars & CADENCE_SUPPORTED != 0 {
			print("Cadence supported: " + String(data[offset]))
			newFitnessMachineState[KEY_NAME_FITNESS_MACHINE_CADENCE] = UInt32(data[offset])
			offset += 1
		}
		if chars & TOTAL_DISTANCE_SUPPORTED != 0 {
			print("Total distance supported: " + String(data[offset]))
			newFitnessMachineState[KEY_NAME_FITNESS_MACHINE_TOTAL_DISTANCE] = UInt32(data[offset])
			offset += 1
		}
		if chars & INCLINATION_SUPPORTED != 0 {
			print("Inclination supported: " + String(data[offset]))
			newFitnessMachineState[KEY_NAME_FITNESS_MACHINE_INCLINATION] = UInt32(data[offset])
			offset += 1
		}
		if chars & ELEVATION_GAIN_SUPPORTED != 0 {
			print("Elevation gain supported")
		}
		if chars & PACE_SUPPORTED != 0 {
			print("Pace supported: " + String(data[offset]))
			newFitnessMachineState[KEY_NAME_FITNESS_MACHINE_PACE] = UInt32(data[offset])
			offset += 1
		}
		if chars & STEP_COUNT_SUPPORTED != 0 {
			print("Step count supported")
		}
		if chars & RESISTANCE_LEVEL_SUPPORTED != 0 {
			print("Resistance supported: " + String(data[offset]))
			newFitnessMachineState[KEY_NAME_FITNESS_MACHINE_RESISTANCE] = UInt32(data[offset])
			offset += 1
		}
		if chars & EXPENDED_ENERGY_SUPPORTED != 0 {
			print("Expended energy supported")
		}
		if chars & HEART_RATE_MEASUREMENT_SUPPORTED != 0 {
			print("Heart rate measurement supported")
		}
		if chars & METABOLIC_EQUIVALENT_SUPPORTED != 0 {
			print("Metabolic equivalent supported")
		}
		if chars & ELAPSED_TIME_SUPPORTED != 0 {
			print("Elapsed time supported")
		}
		if chars & REMAINING_TIME_SUPPORTED != 0 {
			print("Remaining time supported")
		}
		if chars & POWER_MEASUREMENT_SUPPORTED != 0 {
			print("Power measurement supported")
		}
		if chars & FORCE_ON_BELT_AND_POWER_OUTPUT_SUPPORTED != 0 {
			print("Force on belt and power output supported")
		}
		if chars & USER_DATA_RETENTION_SUPPORTED != 0 {
			print("User data retention supported")
		}
	}
	return newFitnessMachineState
}

func decodeFitnessMachineData(data: Data, fitnessMachineState: Dictionary<String, UInt32>) throws -> Dictionary<String, UInt32> {
	if !fitnessMachineState.keys.contains(KEY_NAME_FITNESS_MACHINE_TYPE) {
		return try decodeFitnessMachineService(data: data)
	}
	else if let fitnessMachineType = fitnessMachineState[KEY_NAME_FITNESS_MACHINE_TYPE] {
		let tempFitnessMachineType: UInt16 = numericCast(fitnessMachineType)

		if data.count == 2 {
			return try decodeFitnessMachineCharacteristics(data: data, fitnessMachineState: fitnessMachineState)
		}
		else {
			if tempFitnessMachineType & TREADMILL_SUPPORTED != 0 {
				return try decodeTreadmillCharacteristics(data: data, fitnessMachineState: fitnessMachineState)
			}
			else if tempFitnessMachineType & CROSS_TRAINER_SUPPORTED != 0 {
				return try decodeCrossTrainerCharacteristics(data: data, fitnessMachineState: fitnessMachineState)
			}
			else if tempFitnessMachineType & STEP_CLIMBER_SUPPORTED != 0 {
				return try decodeStepClimberCharacteristics(data: data, fitnessMachineState: fitnessMachineState)
			}
			else if tempFitnessMachineType & STAIR_CLIMBER_SUPPORTED != 0 {
				return try decodeStairClimberCharacteristics(data: data, fitnessMachineState: fitnessMachineState)
			}
			else if tempFitnessMachineType & ROWER_SUPPORTED != 0 {
				return try decodeRowerCharacteristics(data: data, fitnessMachineState: fitnessMachineState)
			}
			else if tempFitnessMachineType & INDOOR_BIKE_SUPPORTED != 0 {
				return try decodeIndoorBikeCharacteristics(data: data, fitnessMachineState: fitnessMachineState)
			}
		}
	}
	throw FitnessMachineException.runtimeError("Unsupported message")
}
