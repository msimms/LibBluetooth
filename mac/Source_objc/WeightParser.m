//
//  WeightParser.m
//  Created by Michael Simms on 6/3/22.
//

#import <Foundation/Foundation.h>
#import "WeightParser.h"

typedef struct TimeDateReading
{
	uint16_t year;
	uint8_t  month;
	uint8_t  day;
	uint8_t  hour;
	uint8_t  minute;
	uint8_t  second;
} __attribute__((packed)) TimeDateReading;

typedef struct Weight
{
	uint32_t weight; // Unit is in kilograms with a resolution of 0.005
} __attribute__((packed)) Weight;

typedef struct WeightMeasurement
{
	uint8_t         flags;
	uint16_t        weightSI;       // Unit is in kilograms with a resolution of 0.005
	uint16_t        weightImperial; // Unit is in pounds with a resolution of 0.01
	uint8_t         userId;
	TimeDateReading timeDate;
	uint16_t        bmi;            // Unit is unitless with a resolution of 0.1
	uint16_t        heightSI;       // Unit is in meters with a resolution of 0.001
	uint16_t        heightImperial; // Unit is in inches with a resolution of 0.1,
} __attribute__((packed)) WeightMeasurement;

typedef struct WeightScaleFeature
{
	uint32_t flags;
} __attribute__((packed)) WeightScaleFeature;

@implementation WeightParser

+ (float)toFloat:(NSData*)data
{
	if (data && [data length] >= sizeof(Weight))
	{
		const Weight* reportData = [data bytes];
		float weightKg = (float)CFSwapInt32LittleToHost(reportData->weight) / (float)200.0;
		return weightKg;
	}
	return 0.0;
}

+ (NSDictionary*)toDict:(NSData*)data
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc]init];

	if (data && [data length] >= sizeof(Weight))
	{
		const Weight* reportData = [data bytes];
		float weightKg = (float)CFSwapInt32LittleToHost(reportData->weight) / (float)200.0;
		[dict setValue:[[NSNumber alloc] initWithFloat:weightKg] forKey:@KEY_NAME_WEIGHT_KG];
		return dict;
	}
	return nil;
}

+ (NSString*)toJson:(NSData*)data
{
	NSDictionary* dict = [WeightParser toDict:data];
	
	if (data)
	{
		NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
		return [[NSString alloc]initWithData: jsonData encoding: NSUTF8StringEncoding];
	}
	return nil;
}

@end
