//
//  FootPodParser.h
//  Created by Michael Simms on 6/4/22.
//

#ifndef FootPodParser_h
#define FootPodParser_h

#import "Parser.h"

/// @brief Key names used with the JSON parser.
#define KEY_NAME_FOOT_STEPS                 "Footsteps"
#define KEY_NAME_CADENCE                    "Cadence"
#define KEY_NAME_STRIDE_LENGTH              "Stride Length"
#define KEY_NAME_RUN_DISTANCE               "Run Distance"
#define KEY_NAME_STRIDE_LENGTH_TIMESTAMP_MS "Time"
#define KEY_NAME_RUN_DISTANCE_TIMESTAMP_MS  "Time"

@interface FootPodParser : Parser

/// @brief Parses the data that was read from the device and returns it as a dictionary.
+ (NSDictionary*)toDict:(NSData*)data;

/// @brief Parses the data that was read from the device and returns it as a JSON string.
+ (NSString*)toJson:(NSData*)data;

@end

#endif /* FootPodParser_h */
