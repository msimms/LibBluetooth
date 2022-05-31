//
//  CyclingCadenceParser.m
//  Created by Michael Simms on 5/11/22.
//

#import <Foundation/Foundation.h>
#import "CyclingCadenceParser.h"

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

@implementation CyclingCadenceParser

+ (NSString*)toJson:(NSData*)data
{
	const CscMeasurement* cscData = [data bytes];
	const RevMeasurement* revData = [data bytes];

	NSMutableDictionary* dict = [[NSMutableDictionary alloc]init];

	if (cscData->flags & WHEEL_REVOLUTION_DATA_PRESENT)
	{
		[dict setValue:[[NSNumber alloc] initWithInt:(int)CFSwapInt16LittleToHost(cscData->cumulativeWheelRevs)] forKey:@KEY_NAME_WHEEL_REV_COUNT];
	}
	if (cscData->flags & CRANK_REVOLUTION_DATA_PRESENT)
	{
		if ([data length] > 5)
		{
			[dict setValue:[[NSNumber alloc] initWithInt:(int)CFSwapInt16LittleToHost(cscData->cumulativeCrankRevs)] forKey:@KEY_NAME_WHEEL_CRANK_COUNT];
			[dict setValue:[[NSNumber alloc] initWithInt:(int)CFSwapInt16LittleToHost(cscData->lastCrankEventTime)] forKey:@KEY_NAME_WHEEL_CRANK_TIME];
		}
		else
		{
			[dict setValue:[[NSNumber alloc] initWithInt:(int)revData->cumulativeCrankRevs] forKey:@KEY_NAME_WHEEL_CRANK_COUNT];
			[dict setValue:[[NSNumber alloc] initWithInt:(int)revData->lastCrankEventTime] forKey:@KEY_NAME_WHEEL_CRANK_TIME];
		}
	}

	NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
	return [[NSString alloc]initWithData: jsonData encoding: NSUTF8StringEncoding ];
}

@end
