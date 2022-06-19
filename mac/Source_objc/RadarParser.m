//
//  RadarParser.m
//  Created by Michael Simms on 5/30/22.
//

#import <Foundation/Foundation.h>
#import "RadarParser.h"

typedef struct RadarMeasurement
{
	uint8_t identifier;
	uint8_t threatMeters;
	uint8_t threatLevel;
} __attribute__((packed)) RadarMeasurement;

@implementation RadarParser

+ (NSDictionary*)toDict:(NSData*)data
{
	//
	// First byte appears to be an identifier and threats appear to follow in 3 byte chunks.
	//

	const uint8_t* reportBytes = [data bytes];
	NSUInteger reportLen = [data length];

	if (reportBytes && reportLen > 0)
	{
		NSUInteger offset = 1;
		NSUInteger threatCount = (reportLen - 1) / sizeof(RadarMeasurement);
		NSUInteger currentThreatNum = 1;

		NSMutableDictionary* dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
									 [NSNumber numberWithUnsignedLong:threatCount], @KEY_NAME_RADAR_THREAT_COUNT,
									 nil];

		while (offset < reportLen)
		{
			const RadarMeasurement* reportData = [data bytes] + offset;

			NSString* keyNameID = [[NSString alloc] initWithFormat:@"%@%lu", @KEY_NAME_RADAR_THREAT_ID, (unsigned long)currentThreatNum];
			NSString* keyNameDistance = [[NSString alloc] initWithFormat:@"%@%lu", @KEY_NAME_RADAR_THREAT_DISTANCE, (unsigned long)currentThreatNum];
			NSString* keyNameLevel = [[NSString alloc] initWithFormat:@"%@%lu", @KEY_NAME_RADAR_THREAT_LEVEL, (unsigned long)currentThreatNum];

			[dict setObject:[NSNumber numberWithUnsignedInt:reportData->identifier] forKey:keyNameID];
			[dict setObject:[NSNumber numberWithUnsignedInt:reportData->threatMeters] forKey:keyNameDistance];
			[dict setObject:[NSNumber numberWithUnsignedInt:reportData->threatLevel] forKey:keyNameLevel];

			++currentThreatNum;
			offset += sizeof(RadarMeasurement);
		}

		return dict;
	}
	return nil;
}

+ (NSString*)toJson:(NSData*)data
{
	NSDictionary* dict = [RadarParser toDict:data];
	
	if (data)
	{
		NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
		return [[NSString alloc]initWithData: jsonData encoding: NSUTF8StringEncoding];
	}
	return nil;
}

@end
