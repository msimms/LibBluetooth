//
//  BluetoothScanner.h
//  Created by Michael Simms on 5/8/22.
//

#ifndef BluetoothScanner_h
#define BluetoothScanner_h

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

/// @brief Definitions for the various callback types: peripheral discovered, service discovered, value read.
typedef bool (*peripheralDiscoveredCb)(CBPeripheral* peripheral, NSString* description);
typedef void (*serviceEnumeratedCb)(CBUUID* serviceId);
typedef void (*valueUpdatedCb)(CBPeripheral* peripheral, CBUUID* serviceId, NSData* value);

/// @brief This class manages the bluetooth session, scanning for peripherals, querying their services, and reporting updated values.
@interface BluetoothScanner : NSObject<CBCentralManagerDelegate, CBPeripheralDelegate>
{
	/// @brief List of peripheral objects currently connected.
	NSMutableArray* connectedPeripherals;

	/// @brief Apple's Bluetooth interface.
	CBCentralManager* centralManager;

	/// @brief List of services that we are searching for. Array is a list of service UUIDs.
	NSArray* serviceIdsToScanFor;

	/// @brief Callback for when a peripheral is discovered.
	peripheralDiscoveredCb peripheralDiscoveryCallback;

	/// @brief Callback for when a service is enumerated.
	serviceEnumeratedCb serviceDiscoveryCallback;

	/// @brief Callback for when a value is updated.
	valueUpdatedCb valueUpdatedCallback;
}

/// @brief Initiates the scanning process. Events are reported through the various callbacks.
- (void)start:(NSArray*)serviceIdsToScanFor
	withPeripheralCallback:(peripheralDiscoveredCb)peripheralCallback
  	withServiceCallback:(serviceEnumeratedCb)serviceCallback
	withValueUpdatedCallback:(valueUpdatedCb)valueUpdatedCallback;

/// @brief Terminates the scanning process.
- (void)stop;

@end

#endif /* BluetoothScanner_h */
