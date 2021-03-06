//
//  HeartRateParser.h
//  Created by Michael Simms on 5/31/22.
//

#pragma once

#include "Parser.h"

/// @brief Key names used with the JSON parser.
#define KEY_NAME_HEART_RATE "Heart Rate"

class HeartRateParser : public Parser
{
public:
	HeartRateParser() {};
	virtual ~HeartRateParser() {};

	/// @brief Simple parser, returns the heart rate value.
	virtual uint16_t toUInt(const uint8_t* data);

	/// @brief Parses the data that was read from the device and returns it as a dictionary.
	virtual std::map<std::string, uint16_t> toDict(const uint8_t* data);

	/// @brief More complex parser, returns all available data as a JSON string.
	virtual std::string toJson(const uint8_t* data);
};
