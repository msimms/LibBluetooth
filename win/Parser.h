//
//  Parser.h
//  Created by Michael Simms on 5/31/22.
//

#pragma once

#include <stdint.h>
#include <string>

class Parser
{
public:
	Parser() {};
	virtual ~Parser() {};

	/// @brief Simple parser, returns the power value.
	virtual uint16_t toUInt(const uint8_t* data) = 0;

	/// @brief More complex parser, returns all available data as a JSON string.
	virtual std::string toJson(const uint8_t* data) = 0;
};
