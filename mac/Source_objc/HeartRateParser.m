//
//  HeartRateParser.m
//  Created by Michael Simms on 5/9/22.
//

#import <Foundation/Foundation.h>
#import "HeartRateParser.h"

#define ERROR_HEART_RATE_CONTROL_POINT_NO_SUPPORTED  0x80

#define FLAGS_HEART_RATE_VALUE             0x01
#define FLAGS_SENSOR_CONTACT_STATUS_VALUE  0x02
#define FLAGS_ENERGY_EXPENDED_STATUS_VALUE 0x04
#define FLAGS_RR_VALUE                     0x08

typedef struct HeartRateMeasurement
{
	uint8_t  flags;
	uint8_t  value8;
	uint16_t value16;
	uint16_t energyExpended;
	uint16_t rrInterval;
} __attribute__((packed)) HeartRateMeasurement;

@implementation HeartRateParser

+ (uint16_t)parse:(NSData*)data
{
	const HeartRateMeasurement* reportData = [data bytes];

	if ((reportData->flags & FLAGS_HEART_RATE_VALUE) == 0)
	{
		return (uint16_t)reportData->value8;
	}
	return CFSwapInt16LittleToHost(reportData->value16);
}

+ (NSDictionary*)toDict:(NSData*)data
{
	const HeartRateMeasurement* reportData = [data bytes];
	NSMutableDictionary* dict = [[NSMutableDictionary alloc]init];

	if ((reportData->flags & FLAGS_HEART_RATE_VALUE) == 0)
	{
		[dict setValue:[[NSNumber alloc] initWithInt:(int)reportData->value8] forKey:@KEY_NAME_HEART_RATE];
	}
	else	// uint16_t
	{
		[dict setValue:[[NSNumber alloc] initWithInt:(int)CFSwapInt16LittleToHost(reportData->value16)] forKey:@KEY_NAME_HEART_RATE];
	}
	return dict;
}

+ (NSString*)toJson:(NSData*)data
{
	NSDictionary* dict = [HeartRateParser toDict:data];
	
	if (data)
	{
		NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
		return [[NSString alloc]initWithData: jsonData encoding: NSUTF8StringEncoding];
	}
	return nil;
}

@end
