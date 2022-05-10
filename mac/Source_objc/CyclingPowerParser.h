//
//  CyclingPowerParser.h
//  Created by Michael Simms on 5/9/22.
//

#ifndef CyclingPowerParser_h
#define CyclingPowerParser_h

@interface CyclingPowerParser : NSObject

+ (uint16_t)parse:(NSData*)data;

@end

#endif /* CyclingPowerParser_h */
