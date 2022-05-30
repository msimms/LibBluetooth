//
//  AppDelegate.m
//  Created by Michael Simms on 5/9/22.
//

#import "AppDelegate.h"
#import "BluetoothServices.h"
#import "CyclingPowerParser.h"
#import "HeartRateParser.h"
#import "RadarParser.h"

CBUUID* extendUUID(uint16_t value)
{
	NSString* str = [[NSString alloc] initWithFormat:@"0000%04X-0000-1000-8000-00805F9B34FB", value];
	return [CBUUID UUIDWithString:str];
}

CBUUID* intToCBUUID(uint16_t value)
{
	return [CBUUID UUIDWithData:[NSData dataWithBytes:&value length:2]];
}

/// Called when a peripheral is discovered.
/// Returns true to indicate that we should connect to this peripheral and discover its services.
bool peripheralDiscovered(CBPeripheral* peripheral, NSString* description)
{
	return true;
}

/// Called when a service is discovered.
void serviceDiscovered(CBUUID* serviceId)
{
}

/// Called when a sensor characteristic is updated.
void valueUpdated(CBPeripheral* peripheral, CBUUID* serviceId, NSData* value)
{
	if ([serviceId isEqual:extendUUID(BT_SERVICE_HEART_RATE)])
	{
		uint16_t hrBpm = [HeartRateParser parse:value];
		NSDictionary* heartRateData = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:hrBpm], @"Heart Rate", nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"Heart Rate Updated" object:heartRateData];
	}
	else if ([serviceId isEqual:extendUUID(BT_SERVICE_CYCLING_POWER)])
	{
		uint16_t powerWatts = [CyclingPowerParser parse:value];
		NSDictionary* powerData = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:powerWatts], @"Power", nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"Power Updated" object:powerData];
	}
	else if ([serviceId isEqual:[CBUUID UUIDWithString:@CUSTOM_BT_SERVICE_VARIA_RADAR]])
	{
		NSString* radarJson = [RadarParser toJson:value];
		NSDictionary* radarData = [[NSDictionary alloc] initWithObjectsAndKeys:radarJson, @"Radar", nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"Radar Updated" object:radarData];
	}
}

BluetoothScanner* startBluetoothScanning(void)
{
	BluetoothScanner* scanner = [[BluetoothScanner alloc] init];

	CBUUID* heartRateSvc = [CBUUID UUIDWithString:[[NSString alloc] initWithFormat:@"%X", BT_SERVICE_HEART_RATE]];
	CBUUID* cyclingPowerSvc = [CBUUID UUIDWithString:[[NSString alloc] initWithFormat:@"%X", BT_SERVICE_CYCLING_POWER]];
	CBUUID* radarSvc = [CBUUID UUIDWithString:@CUSTOM_BT_SERVICE_VARIA_RADAR];

	NSArray* interestingServices = [[NSArray alloc] initWithObjects:heartRateSvc, cyclingPowerSvc, radarSvc, nil];

	// Start scanning for the services that we are interested in.
	[scanner start:interestingServices withPeripheralCallback:&peripheralDiscovered withServiceCallback:&serviceDiscovered withValueUpdatedCallback:&valueUpdated];
	return scanner;
}

@interface AppDelegate ()


@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification*)aNotification
{
	self->scanner = startBluetoothScanning();
}

- (void)applicationWillTerminate:(NSNotification*)aNotification
{
	// Insert code here to tear down your application
	if (self->scanner)
	{
		[self->scanner stop];
	}
}

- (BOOL)applicationSupportsSecureRestorableState:(NSApplication*)app
{
	return YES;
}

@end
