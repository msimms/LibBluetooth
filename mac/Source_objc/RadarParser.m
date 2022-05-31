//
//  RadarParser.m
//  Created by Michael Simms on 5/30/22.
//

#import <Foundation/Foundation.h>
#import "RadarParser.h"

typedef struct RadarMeasurement
{
	uint8_t unknown;
	uint8_t threatSpeedMeters;
	uint8_t threatLevel;
} __attribute__((packed)) RadarMeasurement;

@implementation RadarParser

+ (uint16_t)parse:(NSData*)data
{
	[NSException raise:@"Unimplemented" format:@"Unimplemented method"];
	return 0;
}

+ (NSString*)toJson:(NSData*)data
{
	//
	// Not sure what the first byte is for, but threats appear to follow in 3 byte chunks.
	//

	const uint8_t* reportBytes = [data bytes];
	NSUInteger reportLen = [data length];

	if (reportBytes && reportLen > 0)
	{
		NSUInteger offset = 1;
		NSUInteger threatCount = (reportLen - 1) / sizeof(RadarMeasurement);
		NSUInteger currentThreatNum = 1;

		NSMutableDictionary* radarData = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
										  [NSNumber numberWithUnsignedLong:threatCount], @KEY_NAME_RADAR_THREAT_COUNT,
										  nil];

		while (offset < reportLen)
		{
			const RadarMeasurement* reportData = [data bytes] + offset;

			NSString* keyNameID = [[NSString alloc] initWithFormat:@"%@%lu", @KEY_NAME_RADAR_THREAT_ID, currentThreatNum];
			NSString* keyNameSpeed = [[NSString alloc] initWithFormat:@"%@%lu", @KEY_NAME_RADAR_THREAT_DISTANCE, currentThreatNum];
			NSString* keyNameLevel = [[NSString alloc] initWithFormat:@"%@%lu", @KEY_NAME_RADAR_THREAT_LEVEL, currentThreatNum];

			[radarData setObject:[NSNumber numberWithUnsignedInt:reportData->unknown] forKey:keyNameID];
			[radarData setObject:[NSNumber numberWithUnsignedInt:reportData->threatSpeedMeters] forKey:keyNameSpeed];
			[radarData setObject:[NSNumber numberWithUnsignedInt:reportData->threatLevel] forKey:keyNameLevel];

			++currentThreatNum;
			offset += sizeof(RadarMeasurement);
		}

		NSData* jsonData = [NSJSONSerialization dataWithJSONObject:radarData options:NSJSONWritingPrettyPrinted error:nil];
		return [[NSString alloc]initWithData: jsonData encoding: NSUTF8StringEncoding ];
	}
	return nil;
}

@end
