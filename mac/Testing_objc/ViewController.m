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
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(radarUpdated:) name:@"Radar Updated" object:nil];
	
	self->valueText.backgroundColor = [NSColor whiteColor];
}

/// @brief Notification callback for a heart rate sensor reading.
- (void)heartRateUpdated:(NSNotification*)notification
{
	NSDictionary* msgData = [notification object];
	NSNumber* hr = [msgData objectForKey:@"Heart Rate"];
	NSString* valueStr = [[NSString alloc] initWithFormat:@"Heart Rate: %u bpm\n", hr.intValue];
	NSAttributedString* attrValueStr = [[NSAttributedString alloc] initWithString:valueStr];

	[self->valueText.textStorage appendAttributedString:attrValueStr];
}

/// @brief Notification callback for a cycling power sensor reading.
- (void)cyclingPowerUpdated:(NSNotification*)notification
{
	NSDictionary* msgData = [notification object];
	NSNumber* power = [msgData objectForKey:@"Power"];
	NSString* valueStr = [[NSString alloc] initWithFormat:@"Cycling Power: %u watts\n", power.intValue];
	NSAttributedString* attrValueStr = [[NSAttributedString alloc] initWithString:valueStr];

	[self->valueText.textStorage appendAttributedString:attrValueStr];
}

/// @brief Notification callback for a radar sensor reading.
- (void)radarUpdated:(NSNotification*)notification
{
	NSDictionary* msgData = [notification object];
	NSString* radarStr = [msgData objectForKey:@"Radar"];
	NSAttributedString* attrValueStr = [[NSAttributedString alloc] initWithString:radarStr];

	[self->valueText.textStorage appendAttributedString:attrValueStr];
}

- (void)setRepresentedObject:(id)representedObject
{
	[super setRepresentedObject:representedObject];
}

@end
