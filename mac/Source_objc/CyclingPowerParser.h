//
//  CyclingPowerParser.h
//  Created by Michael Simms on 5/9/22.
//

#ifndef CyclingPowerParser_h
#define CyclingPowerParser_h

@interface CyclingPowerParser : NSObject

/// @brief Simple parser, returns the power value.
+ (uint16_t)parse:(NSData*)data;

/// @brief More complex parser, returns all available data as a JSON string.
+ (NSString*)toJson:(NSData*)data;

@end

#endif /* CyclingPowerParser_h */
