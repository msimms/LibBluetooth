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

/// @brief More complex parser, returns all available data as a JSON string.
+ (NSString*)toJson:(NSData*)data;

@end

#endif /* WeightParser_h */
