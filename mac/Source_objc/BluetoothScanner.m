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
	
	if (!self->connectedPeripherals)
	{
		self->connectedPeripherals = [[NSMutableArray alloc] init];
	}

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

- (void)restart
{
	if ([self->centralManager state] == CBManagerStatePoweredOn)
	{
		NSDictionary* options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
		[self->centralManager scanForPeripheralsWithServices:self->serviceIdsToScanFor options:options];
	}
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
	// Remove the peripheral from the connected list.
	[self stopTrackingConnectedPeripheral:peripheral];
}

- (void)centralManager:(CBCentralManager*)central didDiscoverPeripheral:(CBPeripheral*)peripheral advertisementData:(NSDictionary*)advertisementData RSSI:(NSNumber*)RSSI
{
	// Notify the callback.
	// If the callback returns true then we should connect to the peripheral.
	if (self->peripheralDiscoveryCallback(peripheral, advertisementData.description, self->callbackParam))
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
	[self restart];
}

#pragma mark Peripheral callbacks

- (void)peripheral:(CBPeripheral*)peripheral didDiscoverServices:(NSError*)error
{
	for (CBService* service in peripheral.services)
	{
		for (CBUUID* value in self->serviceIdsToScanFor)
		{
			if ([value isEqual:[service UUID]])
			{
				// Notify callbacks.
				self->serviceDiscoveryCallback(peripheral, [service UUID], self->callbackParam);
				
				// Discover characteristics.
				[peripheral discoverCharacteristics:nil forService:service];
			}
		}
	}
}

- (void)peripheral:(CBPeripheral*)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError*)error
{
}

- (void)peripheral:(CBPeripheral*)peripheral didDiscoverCharacteristicsForService:(CBService*)service error:(NSError*)error
{
	for (CBCharacteristic* characteristic in service.characteristics)
	{
		[peripheral setNotifyValue:TRUE forCharacteristic:characteristic];
		[peripheral readValueForCharacteristic:characteristic];
	}
}

- (void)peripheral:(CBPeripheral*)peripheral didUpdateValueForCharacteristic:(CBCharacteristic*)characteristic error:(NSError*)error
{
	if (characteristic.value != nil)
	{
		self->valueUpdatedCallback(peripheral, characteristic.service.UUID, characteristic.UUID, characteristic.value, self->callbackParam);
	}
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

- (void)start:(NSArray*)serviceIdsToScanFor withPeripheralDiscoveredCallback:(peripheralDiscoveredCb)peripheralCallback withServiceCallback:(serviceEnumeratedCb)serviceCallback withValueUpdatedCallback:(valueUpdatedCb)valueUpdatedCallback withCallbackParam:(void*)callbackParam
{
	self->serviceIdsToScanFor = serviceIdsToScanFor;
	self->peripheralDiscoveryCallback = peripheralCallback;
	self->serviceDiscoveryCallback = serviceCallback;
	self->valueUpdatedCallback = valueUpdatedCallback;
	self->callbackParam = callbackParam;
	self->centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}

- (void)stop
{
	self->centralManager = nil;
}

@end
