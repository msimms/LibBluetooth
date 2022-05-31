//
//  HeartRateParser.h
//  Created by Michael Simms on 5/31/22.
//

#pragma once

#include "Parser.h"

class HeartRateParser : public Parser
{
public:
	HeartRateParser() {};
	virtual ~HeartRateParser() {};

	/// @brief Simple parser, returns the power value.
	virtual uint16_t toUInt(const uint8_t* data);

	/// @brief More complex parser, returns all available data as a JSON string.
	virtual std::string toJson(const uint8_t* data);
};
