//
//  CyclingPowerParser.cpp
//  Created by Michael Simms on 6/6/22.
//

#include "CyclingPowerParser.h"

#define ERROR_INAPPROPRIATE_CONNECTION_PARAMETER 0x80

#define FLAGS_PEDAL_POWER_BALANCE_PRESENT       0x0001
#define FLAGS_PEDAL_POWER_BALANCE_REFERENCE     0x0002
#define FLAGS_ACCUMULATED_TORQUE_PRESENT        0x0004
#define FLAGS_ACCUMULATED_TORQUE_SOURCE         0x0008
#define FLAGS_WHEEL_REVOLUTION_DATA_PRESENT     0x0010
#define FLAGS_CRANK_REVOLUTION_DATA_PRESENT     0x0020
#define FLAGS_EXTREME_FORCE_MAGNITUDES_PRESENT  0x0040
#define FLAGS_EXTREME_TORQUE_MAGNITUDES_PRESENT 0x0080
#define FLAGS_EXTREME_ANGLES_PRESENT            0x0100
#define FLAGS_TOP_DEAD_SPOT_ANGLE_PRESENT       0x0200
#define FLAGS_BOTTOM_DEAD_SPOT_ANGLE_PRESENT    0x0400
#define FLAGS_ACCUMULATED_ENERGY_PRESENT        0x0800
#define FLAGS_OFFSET_COMPENSATION_INDICATOR     0x1000

/// @brief Simple parser, returns the power value.
uint16_t CyclingPowerParser::toUInt(const uint8_t* data)
{
	// First two bytes are the flags
	// Second two bytes are the power
	if (data)
	{
		size_t reportBytesIndex = sizeof(uint16_t);

		const uint8_t* powerBytes = data + reportBytesIndex;
		return BYTE_SWAP(*(uint16_t*)powerBytes);
	}
	return 0;
}

/// @brief Parses the data that was read from the device and returns it as a dictionary.
std::map<std::string, uint16_t> CyclingPowerParser::toDict(const uint8_t* data)
{
	std::map<std::string, uint16_t> result;

	result.insert(std::make_pair(KEY_NAME_CYCLING_POWER_WATTS, this->toUInt(data)));
	return result;
}

/// @brief More complex parser, returns all available data as a JSON string.
std::string CyclingPowerParser::toJson(const uint8_t* data)
{
	return "";
}
