//
//  BluetoothScanner.h
//  Created by Michael Simms on 5/8/22.
//

#ifndef BluetoothScanner_h
#define BluetoothScanner_h

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

typedef bool (*peripheralCb)(NSString*);
typedef void (*serviceCB)(CBUUID*);
typedef void (*valueCB)(CBPeripheral*, CBUUID*, NSData*);

@interface BluetoothScanner : NSObject<CBCentralManagerDelegate, CBPeripheralDelegate>
{
	/// List of peripheral objects currently connected.
	NSMutableArray* connectedPeripherals;

	/// Apple's Bluetooth interface.
	CBCentralManager* centralManager;

	/// List of services that we are searching for.
	NSArray* serviceIdsToScanFor;

	/// Callback for when a peripheral is discovered.
	peripheralCb peripheralDiscoveryCallback;

	/// Callback for when a service is discovered.
	serviceCB serviceDiscoveryCallback;

	/// Callback for when a value is updated.
	valueCB valueUpdatedCallback;
}

- (void)startScanning:(NSArray*)serviceIdsToScanFor withPeripheralCallback:(peripheralCb)peripheralCallback withServiceCallback:(serviceCB)serviceCallback withValueUpdatedCallback:(valueCB)valueUpdatedCallback;
- (void)stopScanner;

@end

#endif /* BluetoothScanner_h */
