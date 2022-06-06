//
//  Parser.h
//  Created by Michael Simms on 5/31/22.
//

#pragma once

#include <stdint.h>
#include <string>
#include <map>

#define BYTE_SWAP(x) ((x & 0xff) << 8) | ((x & 0xff00) >> 8)

class Parser
{
public:
	Parser() {};
	virtual ~Parser() {};

	/// @brief Simple parser, returns the power value.
	virtual uint16_t toUInt(const uint8_t* data) = 0;

	/// @brief Parses the data that was read from the device and returns it as a dictionary.
	virtual std::map<std::string, uint16_t> toDict(const uint8_t* data) = 0;

	/// @brief More complex parser, returns all available data as a JSON string.
	virtual std::string toJson(const uint8_t* data) = 0;
};
