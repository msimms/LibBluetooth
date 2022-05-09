//
//  main.m
//  Created by Michael Simms on 5/8/22.
//

#import <Foundation/Foundation.h>
#import "BluetoothScanner.h"
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

int main(int argc, const char * argv[]) {
	@autoreleasepool {
		BluetoothScanner* scanner = startBluetoothScanning();
		dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
		dispatch_group_t group = dispatch_group_create();
		 
		// Add a task to the group
		dispatch_group_async(group, queue, ^{
		   // Some asynchronous work
			sleep(60000);
		});
		 
		// Do some other work while the tasks execute.
		 
		// When you cannot make any more forward progress,
		// wait on the group to block the current thread.
		dispatch_group_wait(group, DISPATCH_TIME_FOREVER);

		[scanner stopScanner];
	}
	return 0;
}
