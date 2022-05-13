//
//  AppDelegate.m
//  Created by Michael Simms on 5/9/22.
//

#import "AppDelegate.h"
#import "BluetoothServices.h"
#import "CyclingPowerParser.h"
#import "HeartRateParser.h"

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
bool peripheralDiscovered(NSString* description)
{
	return true;
}

/// Called when a service is discovered.
void serviceDiscovered(CBUUID* serviceId)
{
}

/// Called when a sensor characteristic is updated.
void valueUpdated(CBPeripheral* peripheralObj, CBUUID* serviceId, NSData* value)
{
	if ([serviceId isEqual:extendUUID(BT_SERVICE_HEART_RATE)])
	{
		uint16_t hr = [HeartRateParser parse:value];
		NSDictionary* heartRateData = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:hr], @"Heart Rate", nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"Heart Rate Updated" object:heartRateData];
	}
	else if ([serviceId isEqual:extendUUID(BT_SERVICE_CYCLING_POWER)])
	{
		uint16_t power = [CyclingPowerParser parse:value];
		NSDictionary* heartRateData = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:power], @"Power", nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"Power Updated" object:heartRateData];
	}
}

BluetoothScanner* startBluetoothScanning(void)
{
	BluetoothScanner* scanner = [[BluetoothScanner alloc] init];

	CBUUID* heartRateSvc = [CBUUID UUIDWithString:[[NSString alloc] initWithFormat:@"%X", BT_SERVICE_HEART_RATE]];
	CBUUID* cyclingPowerSvc = [CBUUID UUIDWithString:[[NSString alloc] initWithFormat:@"%X", BT_SERVICE_CYCLING_POWER]];

	NSArray* interestingServices = [[NSArray alloc] initWithObjects:heartRateSvc, cyclingPowerSvc, nil];

	// Start scanning for the services that we are interested in.
	[scanner startScanning:interestingServices withPeripheralCallback:&peripheralDiscovered withServiceCallback:&serviceDiscovered withValueUpdatedCallback:&valueUpdated];
	return scanner;
}

@interface AppDelegate ()


@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	self->scanner = startBluetoothScanning();
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}


- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
	return YES;
}


@end
