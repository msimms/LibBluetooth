//
//  CyclingCadenceParser.h
//  Created by Michael Simms on 5/11/22.
//

#ifndef CyclingCadenceParser_h
#define CyclingCadenceParser_h

@interface CyclingCadenceParser : NSObject

/// @brief Returns all available data as a JSON string.
+ (NSString*)toJson:(NSData*)data;

@end

#endif /* CyclingCadenceParser_h */
