//
//  HeartRateParser.cpp
//  Created by Michael Simms on 5/31/22.
//

#include "HeartRateParser.h"

#define ERROR_HEART_RATE_CONTROL_POINT_NO_SUPPORTED  0x80

#define FLAGS_HEART_RATE_VALUE             0x01
#define FLAGS_SENSOR_CONTACT_STATUS_VALUE  0x02
#define FLAGS_ENERGY_EXPENDED_STATUS_VALUE 0x04
#define FLAGS_RR_VALUE                     0x08

typedef struct HeartRateMeasurement
{
	uint8_t  flags;
	uint8_t  value8;
	uint16_t value16;
	uint16_t energyExpended;
	uint16_t rrInterval;
} __pragma(pack(push, 1)) HeartRateMeasurement;

/// @brief Simple parser, returns the heart rate value.
uint16_t HeartRateParser::toUInt(const uint8_t* data)
{
	const HeartRateMeasurement* reportData = reinterpret_cast<const HeartRateMeasurement*>(data);

	if ((reportData->flags & FLAGS_HEART_RATE_VALUE) == 0)
	{
		return (uint16_t)reportData->value8;
	}
	return BYTE_SWAP(reportData->value16);
}

/// @brief Parses the data that was read from the device and returns it as a dictionary.
std::map<std::string, uint16_t> HeartRateParser::toDict(const uint8_t* data)
{
	std::map<std::string, uint16_t> result;

	result.insert(std::make_pair(KEY_NAME_HEART_RATE, this->toUInt(data)));
	return result;
}

/// @brief More complex parser, returns all available data as a JSON string.
std::string HeartRateParser::toJson(const uint8_t* data)
{
	return "";
}
