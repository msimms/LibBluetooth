//
//  CyclingPowerParser.m
//  Created by Michael Simms on 5/9/22.
//

#import <Foundation/Foundation.h>
#import "CyclingPowerParser.h"

#define ERROR_INAPPROPRIATE_CONNECTION_PARAMETER 0x80

#define FLAGS_PEDAL_POWER_BALANCE_PRESENT       0x0001
#define FLAGS_PEDAL_POWER_BALANCE_REFERENCE     0x0002
#define FLAGS_ACCUMULATED_TORQUE_PRESENT        0x0004
#define FLAGS_ACCUMULATED_TORQUE_SOURCE         0x0008
#define FLAGS_WHEEL_REVOLUTION_DATA_PRESENT     0x0010
#define FLAGS_CRANK_REVOLUTION_DATA_PRESENT     0x0020
#define FLAGS_EXTREME_FORCE_MAGNITUDES_PRESENT  0x0040
#define FLAGS_EXTREME_TORQUE_MAGNITUDES_PRESENT 0x0080
#define FLAGS_EXTREME_ANGLES_PRESENT            0x0100
#define FLAGS_TOP_DEAD_SPOT_ANGLE_PRESENT       0x0200
#define FLAGS_BOTTOM_DEAD_SPOT_ANGLE_PRESENT    0x0400
#define FLAGS_ACCUMULATED_ENERGY_PRESENT        0x0800
#define FLAGS_OFFSET_COMPENSATION_INDICATOR     0x1000

@implementation CyclingPowerParser

+ (uint16_t)parse:(NSData*)data
{
	if (data == nil)
	{
		return 0;
	}

	const uint8_t* reportBytes = [data bytes];
	NSUInteger reportLen = [data length];

	if (reportBytes && (reportLen > 4))
	{
		size_t reportBytesIndex = 0;

		uint16_t flags = CFSwapInt16LittleToHost(*(uint16_t*)reportBytes);
		reportBytesIndex += sizeof(uint16_t);

		const uint8_t* powerBytes = reportBytes + reportBytesIndex;
		int16_t power = CFSwapInt16LittleToHost(*(uint16_t*)powerBytes);
		reportBytesIndex += sizeof(int16_t);
		
		if (flags & FLAGS_PEDAL_POWER_BALANCE_PRESENT)
		{
			reportBytesIndex += sizeof(uint8_t);
		}
		if (flags & FLAGS_ACCUMULATED_TORQUE_PRESENT)
		{
			reportBytesIndex += sizeof(uint16_t);
		}
		if (flags & FLAGS_WHEEL_REVOLUTION_DATA_PRESENT)
		{
			reportBytesIndex += sizeof(uint32_t);
			reportBytesIndex += sizeof(uint16_t);
		}
		if ((flags & FLAGS_CRANK_REVOLUTION_DATA_PRESENT) && (reportBytesIndex <= reportLen - sizeof(uint16_t) - sizeof(uint16_t)))
		{
			const uint8_t* crankRevsBytes = reportBytes + reportBytesIndex;
			uint16_t crankRevs = CFSwapInt16LittleToHost(*(uint16_t*)crankRevsBytes);
			reportBytesIndex += sizeof(uint16_t);

			const uint8_t* lastCrankTimeBytes = reportBytes + reportBytesIndex;
			uint16_t lastCrankTime = CFSwapInt16LittleToHost(*(uint16_t*)lastCrankTimeBytes);
			reportBytesIndex += sizeof(uint16_t);
		}
		
		return power;
	}
	return 0;
}

@end
