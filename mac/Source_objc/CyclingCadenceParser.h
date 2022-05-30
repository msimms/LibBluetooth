//
//  CyclingCadenceParser.h
//  Created by Michael Simms on 5/11/22.
//

#ifndef CyclingCadenceParser_h
#define CyclingCadenceParser_h

#import "Parser.h"

/// @brief Key names used with the JSON parser.
#define KEY_NAME_WHEEL_REV_COUNT   "Wheel Rev Count"
#define KEY_NAME_WHEEL_CRANK_COUNT "Crank Count"
#define KEY_NAME_WHEEL_CRANK_TIME  "Crank Time"

@interface CyclingCadenceParser : Parser

/// @brief Returns all available data as a JSON string.
+ (NSString*)toJson:(NSData*)data;

@end

#endif /* CyclingCadenceParser_h */
