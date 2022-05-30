//
//  CyclingPowerParser.h
//  Created by Michael Simms on 5/9/22.
//

#ifndef CyclingPowerParser_h
#define CyclingPowerParser_h

#import "Parser.h"

/// @brief Key names used with the JSON parser.
#define KEY_NAME_CYCLING_POWER_WATTS           "Power"
#define KEY_NAME_CYCLING_POWER_CRANK_REVS      "Crank Revs"
#define KEY_NAME_CYCLING_POWER_LAST_CRANK_TIME "Last Crank Time"

@interface CyclingPowerParser : Parser

/// @brief Simple parser, returns the power value.
+ (uint16_t)parse:(NSData*)data;

/// @brief More complex parser, returns all available data as a JSON string.
+ (NSString*)toJson:(NSData*)data;

@end

#endif /* CyclingPowerParser_h */
