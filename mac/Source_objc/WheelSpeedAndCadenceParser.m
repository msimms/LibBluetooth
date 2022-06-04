//
//  WheelSpeedAndCadenceParser.m
//  Created by Michael Simms on 6/3/22.
//

#import <Foundation/Foundation.h>
#import "WheelSpeedAndCadenceParser.h"

#define ERROR_PROCEDURE_ALREADY_IN_PROGRESS 0x80
#define ERROR_CLIENT_CHARACTERISTIC_CONFIG_DESC_IMPROPERLY_CONFIGURED 0x81

#define WHEEL_REVOLUTION_DATA_PRESENT 0x01
#define CRANK_REVOLUTION_DATA_PRESENT 0x02

typedef struct CscMeasurement
{
	uint8_t  flags;
	uint32_t cumulativeWheelRevs;
	uint16_t lastWheelEventTime;
	uint16_t cumulativeCrankRevs;
	uint16_t lastCrankEventTime;
} __attribute__((packed)) CscMeasurement;

typedef struct RevMeasurement
{
	uint8_t  flags;
	uint16_t cumulativeCrankRevs;
	uint16_t lastCrankEventTime;
} __attribute__((packed)) RevMeasurement;

@implementation WheelSpeedAndCadenceParser

+ (NSDictionary*)toDict:(NSData*)data
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc]init];

	const CscMeasurement* cscData = [data bytes];
	const RevMeasurement* revData = [data bytes];

	if (cscData->flags & WHEEL_REVOLUTION_DATA_PRESENT)
	{
		uint16_t currentWheelRevCount = CFSwapInt16LittleToHost(cscData->cumulativeWheelRevs);
		[dict setObject:[NSNumber numberWithUnsignedInt:currentWheelRevCount] forKey:@KEY_NAME_WHEEL_SPEED];
	}

	if (cscData->flags & CRANK_REVOLUTION_DATA_PRESENT)
	{
		uint16_t currentCrankCount = 0;
		uint16_t currentCrankTime  = 0;

		if ([data length] > 5)
		{
			currentCrankCount = CFSwapInt16LittleToHost(cscData->cumulativeCrankRevs);
			currentCrankTime = CFSwapInt16LittleToHost(cscData->lastCrankEventTime);
		}
		else
		{
			currentCrankCount = CFSwapInt16LittleToHost(revData->cumulativeCrankRevs);
			currentCrankTime = CFSwapInt16LittleToHost(revData->lastCrankEventTime);
		}

		[dict setObject:[NSNumber numberWithUnsignedInt:currentCrankCount] forKey:@KEY_NAME_CRANK_COUNT];
		[dict setObject:[NSNumber numberWithUnsignedInt:currentCrankTime] forKey:@KEY_NAME_CRANK_TIME];
	}
	
	return dict;
}

+ (NSString*)toJson:(NSData*)data
{
	NSDictionary* dict = [WheelSpeedAndCadenceParser toDict:data];

	if (data)
	{
		NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
		return [[NSString alloc]initWithData: jsonData encoding: NSUTF8StringEncoding];
	}
	return nil;

}

@end
