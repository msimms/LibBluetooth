//
//  RadarParser.h
//  Created by Michael Simms on 5/30/22.
//

#ifndef RadarParser_h
#define RadarParser_h

#import "Parser.h"

/// @brief Key names used with the JSON parser.
#define KEY_NAME_RADAR_THREAT_COUNT    "Threat Count"
#define KEY_NAME_RADAR_THREAT_ID       "Threat ID "
#define KEY_NAME_RADAR_THREAT_DISTANCE "Threat Distance "
#define KEY_NAME_RADAR_THREAT_LEVEL    "Threat Level "
#define KEY_NAME_RADAR_TIMESTAMP_MS    "Time"
#define KEY_NAME_RADAR_PERIPHERAL_OBJ  "Peripheral"

@interface RadarParser : Parser

/// @brief Parses the data that was read from the device and returns it as a dictionary.
+ (NSDictionary*)toDict:(NSData*)data;

/// @brief Parses the data that was read from the device and returns it as a JSON string.
+ (NSString*)toJson:(NSData*)data;

@end

#endif /* RadarParser_h */
