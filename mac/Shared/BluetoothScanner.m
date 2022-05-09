//
//  BluetoothScanner.m
//  Created by Michael Simms on 5/8/22.
//

#import "BluetoothScanner.h"

@implementation BluetoothScanner

#pragma mark Internal state management functions

- (void)startTrackingConnectedPeripheral:(CBPeripheral*)peripheral
{
	bool found = false;

	for (CBPeripheral* temp in self->connectedPeripherals)
	{
		if (temp == peripheral)
		{
			found = true;
			break;
		}
	}

	if (!found)
	{
		[self->connectedPeripherals addObject:peripheral];
		peripheral.delegate = self;
	}
}

- (void)stopTrackingConnectedPeripheral:(CBPeripheral*)peripheral
{
	[self->connectedPeripherals removeObject:peripheral];
}

- (bool)isTrackedPeripheral:(CBPeripheral*)peripheral
{
	for (CBPeripheral* temp in self->connectedPeripherals)
	{
		if (temp == peripheral)
		{
			return true;
		}
	}
	return false;
}

#pragma mark Central Manager callbacks

- (void)centralManager:(CBCentralManager*)central didConnectPeripheral:(CBPeripheral*)peripheral
{
	// Discover any relevant services.
	if ([self isTrackedPeripheral:peripheral])
	{
		[peripheral discoverServices:self->serviceIdsToScanFor];
	}
}

- (void)centralManager:(CBCentralManager*)central didDisconnectPeripheral:(CBPeripheral*)peripheral error:(NSError*)error
{
}

- (void)centralManager:(CBCentralManager*)central didDiscoverPeripheral:(CBPeripheral*)peripheral advertisementData:(NSDictionary*)advertisementData RSSI:(NSNumber*)RSSI
{
	// Notify the callback.
	// If the callback returns true then we should connect to the peripheral.
	if (self->peripheralDiscoveryCallback(advertisementData.description))
	{
		[self->centralManager connectPeripheral:peripheral options:nil];
		[self startTrackingConnectedPeripheral:peripheral];
	}
}

- (void)centralManager:(CBCentralManager*)central didFailToConnectPeripheral:(CBPeripheral*)peripheral error:(NSError*)error
{
}

- (void)centralManager:(CBCentralManager*)central didRetrieveConnectedPeripherals:(NSArray*)peripherals
{
}

- (void)centralManager:(CBCentralManager*)central didRetrievePeripherals:(NSArray*)peripherals
{
}

- (void)centralManagerDidUpdateState:(CBCentralManager*)central
{
}

#pragma mark Peripheral callbacks

- (void)peripheral:(CBPeripheral*)peripheral didDiscoverServices:(NSError*)error
{
}

- (void)peripheral:(CBPeripheral*)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError*)error
{
}

- (void)peripheral:(CBPeripheral*)peripheral didDiscoverCharacteristicsForService:(CBService*)service error:(NSError*)error
{
}

- (void)peripheral:(CBPeripheral*)peripheral didUpdateValueForCharacteristic:(CBCharacteristic*)characteristic error:(NSError*)error
{
}

- (void)peripheral:(CBPeripheral*)peripheral didUpdateValueForDescriptor:(CBDescriptor*)descriptor error:(NSError*)error
{
}

- (void)peripheral:(CBPeripheral*)peripheral didWriteValueForCharacteristic:(CBCharacteristic*)characteristic error:(NSError*)error
{
}

- (void)peripheral:(CBPeripheral*)peripheral didWriteValueForDescriptor:(CBDescriptor*)descriptor error:(NSError*)error
{
}

- (void)peripheral:(CBPeripheral*)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic*)characteristic error:(NSError*)error
{
}

#pragma mark Public interface for this class

- (void)startScanning:(NSArray*)serviceIdsToScanFor withPeripheralCallback:(peripheralCb)peripheralCallback withServiceCallback:(serviceCB)serviceCallback withValueUpdatedCallback:(valueCB)valueUpdatedCallback
{
	self->serviceIdsToScanFor = serviceIdsToScanFor;
	self->peripheralDiscoveryCallback = peripheralCallback;
	self->serviceDiscoveryCallback = serviceCallback;
	self->valueUpdatedCallback = valueUpdatedCallback;
	self->centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
}

- (void)stopScanner
{
	self->centralManager = nil;
}

@end
