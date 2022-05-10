//
//  ViewController.m
//  Created by Michael Simms on 5/9/22.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad
{
	[super viewDidLoad];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(heartRateUpdated:) name:@"Heart Rate Updated" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cyclingPowerUpdated:) name:@"Power Updated" object:nil];
}

/// @brief Notification callback for a heart rate sensor reading.
- (void)heartRateUpdated:(NSNotification*)notification
{
	NSDictionary* msgData = [notification object];
	NSNumber* hr = [msgData objectForKey:@"Heart Rate"];
	NSString* valueStr = [[NSString alloc] initWithFormat:@"%u", hr.intValue];
	[self->valueHeartRate setStringValue:valueStr];
}

/// @brief Notification callback for a cycling power sensor reading.
- (void)cyclingPowerUpdated:(NSNotification*)notification
{
}

- (void)setRepresentedObject:(id)representedObject
{
	[super setRepresentedObject:representedObject];
}

@end
