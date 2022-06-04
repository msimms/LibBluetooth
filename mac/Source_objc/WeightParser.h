//
//  WeightParser.h
//  Created by Michael Simms on 6/3/22.
//

#ifndef WeightParser_h
#define WeightParser_h

#import "Parser.h"

/// @brief Key names used with the JSON parser.
#define KEY_NAME_WEIGHT_KG "WeightKg"

@interface WeightParser : Parser

/// @brief Simple parser, returns the weight.
+ (float)toFloat:(NSData*)data;

/// @brief Parses the data that was read from the device and returns it as a dictionary.
+ (NSDictionary*)toDict:(NSData*)data;

/// @brief Parses the data that was read from the device and returns it as a JSON string.
+ (NSString*)toJson:(NSData*)data;

@end

#endif /* WeightParser_h */
