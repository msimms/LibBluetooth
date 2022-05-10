//
//  HeartRateParser.h
//  Created by Michael Simms on 5/9/22.
//

#ifndef HeartRateParser_h
#define HeartRateParser_h

@interface HeartRateParser : NSObject

+ (uint16_t)parse:(NSData*)data;

@end

#endif /* HeartRateParser_h */
