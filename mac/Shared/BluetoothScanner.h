//
//  BluetoothScanner.h
//  Created by Michael Simms on 5/8/22.
//

#ifndef BluetoothScanner_h
#define BluetoothScanner_h

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface BluetoothScanner : NSObject<CBCentralManagerDelegate, CBPeripheralDelegate>
{
	NSArray* serviceIdsToScanFor;
	NSArray* peripheralDiscoveryCallbacks;
	NSArray* serviceDiscoveryCallbacks;
	NSArray* valueUpdatedCallbacks;
	CBCentralManager* centralManager;
}

- (void)startScanning:(NSArray*)serviceIdsToScanFor withPeripheralCallbacks:(NSArray*)peripheralCallbacks withServiceCallbacks:(NSArray*)serviceCallbacks withValueUpdatedCallbacks:(NSArray*)valueUpdatedCallbacks;
- (void)stopScanner;

@end

#endif /* BluetoothScanner_h */
