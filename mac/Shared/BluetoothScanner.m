//
//  BluetoothScanner.m
//  Created by Michael Simms on 5/8/22.
//

#import "BluetoothScanner.h"

@implementation BluetoothScanner

#pragma mark Central Manager callbacks

- (void)centralManager:(CBCentralManager*)central didConnectPeripheral:(CBPeripheral*)peripheral
{
}

- (void)centralManager:(CBCentralManager*)central didDisconnectPeripheral:(CBPeripheral*)peripheral error:(NSError*)error
{
}

- (void)centralManager:(CBCentralManager*)central didDiscoverPeripheral:(CBPeripheral*)peripheral advertisementData:(NSDictionary*)advertisementData RSSI:(NSNumber*)RSSI
{
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

- (void)startScanning:(NSArray*)serviceIdsToScanFor withPeripheralCallbacks:(NSArray*)peripheralCallbacks withServiceCallbacks:(NSArray*)serviceCallbacks withValueUpdatedCallbacks:(NSArray*)valueUpdatedCallbacks
{
	self->serviceIdsToScanFor = serviceIdsToScanFor;
	self->peripheralDiscoveryCallbacks = peripheralCallbacks;
	self->serviceDiscoveryCallbacks = serviceCallbacks;
	self->valueUpdatedCallbacks = valueUpdatedCallbacks;
	self->centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
}

- (void)stopScanner
{
	self->centralManager = nil;
}

@end
