//
//  FootPodParser.m
//  Created by Michael Simms on 6/4/22.
//

#import <Foundation/Foundation.h>
#import "FootPodParser.h"

typedef struct RscMeasurement
{
	uint8_t  information;
	uint16_t instSpeed;        // meters per second
	uint8_t  instCadence;      // rpm
	uint16_t instStrideLength; // meters
	uint32_t totalDistance;
} __attribute__((packed)) RscMeasurement;

#define FLAGS_INSTANTANEOUS_STRIDE_LENGTH_PRESENT    0x0001
#define FLAGS_TOTAL_DISTANCE_PRESENT                 0x0002
#define FLAGS_WALKING_OR_RUNNING_STATUS_BITS         0x0004
#define FLAGS_SENSOR_CALIBRATION_PROCEDURE_SUPPORTED 0x0008
#define FLAGS_MULTIPLE_SENSOR_LOCATION_SUPPORTED     0x0010

@implementation FootPodParser

+ (NSDictionary*)toDict:(NSData*)data
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc]init];

	if (data && [data length] >= sizeof(RscMeasurement))
	{
		const RscMeasurement* measurement = [data bytes];

		if (measurement->information & FLAGS_INSTANTANEOUS_STRIDE_LENGTH_PRESENT)
		{
			uint32_t stride = CFSwapInt32LittleToHost(measurement->instCadence);
			[dict setObject:[NSNumber numberWithInt:stride] forKey:@KEY_NAME_STRIDE_LENGTH];
		}
		if (measurement->information & FLAGS_TOTAL_DISTANCE_PRESENT)
		{
			uint32_t distance = CFSwapInt32LittleToHost(measurement->totalDistance);
			[dict setObject:[NSNumber numberWithUnsignedLong:distance] forKey:@KEY_NAME_RUN_DISTANCE];
		}
		if (measurement->information & FLAGS_WALKING_OR_RUNNING_STATUS_BITS)
		{
		}
	}

	return dict;
}

+ (NSString*)toJson:(NSData*)data
{
	NSDictionary* dict = [FootPodParser toDict:data];
	
	if (data)
	{
		NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
		return [[NSString alloc]initWithData: jsonData encoding: NSUTF8StringEncoding];
	}
	return nil;
}

@end
