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

#define BYTE_SWAP(x) ((x & 0xff) << 8) | ((x & 0xff00) >> 8)


typedef struct HeartRateMeasurement
{
	uint8_t  flags;
	uint8_t  value8;
	uint16_t value16;
	uint16_t energyExpended;
	uint16_t rrInterval;
} __pragma(pack(push, 1)) HeartRateMeasurement;

/// @brief Simple parser, returns the power value.
uint16_t HeartRateParser::toUInt(const uint8_t* data)
{
	const HeartRateMeasurement* reportData = reinterpret_cast<const HeartRateMeasurement*>(data);

	if ((reportData->flags & FLAGS_HEART_RATE_VALUE) == 0)
	{
		return (uint16_t)reportData->value8;
	}
	return BYTE_SWAP(reportData->value16);
}

/// @brief More complex parser, returns all available data as a JSON string.
std::string HeartRateParser::toJson(const uint8_t* data)
{
	return "";
}
