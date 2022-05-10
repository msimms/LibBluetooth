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
	if (!data)
	{
		return 0;
	}

	const HeartRateMeasurement* reportData = [data bytes];

	if ((reportData->flags & FLAGS_HEART_RATE_VALUE) == 0)
	{
		return (uint16_t)reportData->value8;
	}
	else	// uint16_t
	{
		return CFSwapInt16LittleToHost(reportData->value16);
	}
}

@end
