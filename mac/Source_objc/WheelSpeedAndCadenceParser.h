//
//  WheelSpeedAndCadenceParser.h
//  Created by Michael Simms on 6/3/22.
//

#ifndef WheelSpeedAndCadenceParser_h
#define WheelSpeedAndCadenceParser_h

#import "Parser.h"

/// @brief Key names used with the JSON parser.
#define KEY_NAME_WHEEL_SPEED "Wheel Speed"
#define KEY_NAME_CRANK_COUNT "Crank Count"
#define KEY_NAME_CRANK_TIME  "Crank Time"

@interface WheelSpeedAndCadenceParser : Parser

/// @brief Returns all available data as a JSON string.
+ (NSString*)toJson:(NSData*)data;

@end

#endif /* WheelSpeedAndCadenceParser_h */
