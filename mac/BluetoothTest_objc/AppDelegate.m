//
//  AppDelegate.m
//  Created by Michael Simms on 5/9/22.
//

#import "AppDelegate.h"
#import "BluetoothServices.h"

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
void valueUpdated(CBPeripheral* peripheral, CBUUID* serviceId, NSData* value)
{
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
