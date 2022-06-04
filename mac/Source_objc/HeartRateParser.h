//
//  HeartRateParser.h
//  Created by Michael Simms on 5/9/22.
//

#ifndef HeartRateParser_h
#define HeartRateParser_h

#import "Parser.h"

/// @brief Key names used with the JSON parser.
#define KEY_NAME_HEART_RATE "Heart Rate"

@interface HeartRateParser : Parser

/// @brief Simple parser, returns the heart rate.
+ (uint16_t)parse:(NSData*)data;

/// @brief Parses the data that was read from the device and returns it as a dictionary.
+ (NSDictionary*)toDict:(NSData*)data;

/// @brief Parses the data that was read from the device and returns it as a JSON string.
+ (NSString*)toJson:(NSData*)data;

@end

#endif /* HeartRateParser_h */
