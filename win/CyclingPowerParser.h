//
//  CyclingPowerParser.h
//  Created by Michael Simms on 6/6/22.
//

#pragma once

#include "Parser.h"

/// @brief Key names used with the JSON parser.
#define KEY_NAME_CYCLING_POWER_WATTS           "Power"
#define KEY_NAME_CYCLING_POWER_CRANK_REVS      "Crank Revs"
#define KEY_NAME_CYCLING_POWER_LAST_CRANK_TIME "Last Crank Time"

class CyclingPowerParser : public Parser
{
public:
	CyclingPowerParser() {};
	virtual ~CyclingPowerParser() {};

	/// @brief Simple parser, returns the power value.
	virtual uint16_t toUInt(const uint8_t* data);

	/// @brief Parses the data that was read from the device and returns it as a dictionary.
	virtual std::map<std::string, uint16_t> toDict(const uint8_t* data);

	/// @brief More complex parser, returns all available data as a JSON string.
	virtual std::string toJson(const uint8_t* data);
};
