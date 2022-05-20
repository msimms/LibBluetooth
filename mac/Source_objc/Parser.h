//
//  Parser.h
//  Created by Michael Simms on 5/20/22.
//

#ifndef Parser_h
#define Parser_h

@interface Parser : NSObject

/// @brief Simple parser, returns the power value.
+ (uint16_t)parse:(NSData*)data;

/// @brief More complex parser, returns all available data as a JSON string.
+ (NSString*)toJson:(NSData*)data;

@end

#endif /* Parser_h */
