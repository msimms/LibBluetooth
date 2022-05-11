//
//  HeartRateParser.h
//  Created by Michael Simms on 5/9/22.
//

#ifndef HeartRateParser_h
#define HeartRateParser_h

@interface HeartRateParser : NSObject

/// @brief Simple parser, returns the heart rate.
+ (uint16_t)parse:(NSData*)data;

/// @brief More complex parser, returns all available data as a JSON string.
+ (NSString*)toJson:(NSData*)data;

@end

#endif /* HeartRateParser_h */
