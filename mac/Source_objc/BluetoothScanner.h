//
//  BluetoothScanner.h
//  Created by Michael Simms on 5/8/22.
//

#ifndef BluetoothScanner_h
#define BluetoothScanner_h

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

/// @brief Definitions for the various callback types: peripheral discovered, service discovered, value read.
typedef bool (*peripheralCb)(NSString* description);
typedef void (*serviceCB)(CBUUID* serviceId);
typedef void (*valueCB)(CBPeripheral* peripheralObj, CBUUID* serviceId, NSData* value);

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
	peripheralCb peripheralDiscoveryCallback;

	/// @brief Callback for when a service is discovered.
	serviceCB serviceDiscoveryCallback;

	/// @brief Callback for when a value is updated.
	valueCB valueUpdatedCallback;
}

/// @brief Initiates the scanning process. Events are reported through the various callbacks.
- (void)startScanning:(NSArray*)serviceIdsToScanFor
	withPeripheralCallback:(peripheralCb)peripheralCallback
  	withServiceCallback:(serviceCB)serviceCallback
	withValueUpdatedCallback:(valueCB)valueUpdatedCallback;

/// @brief Terminates the scanning process.
- (void)stopScanner;

@end

#endif /* BluetoothScanner_h */
