# LibBluetooth
A cross platform Bluetooth library. The goal is to have a simple library that implements the functionality required for the most common Bluetooth uses cases, i.e. reading from a heart rate monitor, or similar device.

Initial focus is on Bluetooth LE devices, but more general Bluetooth support may be added in the future.

## Supported Platforms
* macOS (Objective-C and Swift) - Successfully tested with a heart rate monitor, cycling power meter, cycling cadence sensor, and cycling radar.
* iOS (Objective-C and Swift) - Successfully tested with a heart rate monitor, cycling power meter, cycling cadence sensor, and cycling radar.
* Windows (C/C++) - Currently in-progress
* Android (planned)

## Interface
The interface basically consists of just two methods: *start* and *stop*, with feedback being provided via callback functions.

### mac OS and iOS ###

Objective C

	- (void)start:(NSArray*)serviceIdsToScanFor
	    withPeripheralCallback:(peripheralDiscoveredCb)peripheralCallback
	    withServiceCallback:(serviceEnumeratedCb)serviceCallback
	    withValueUpdatedCallback:(valueUpdatedCb)valueUpdatedCallback;
	- (void)stop;

Swift

	func startScanningForServices(serviceIdsToScanFor: Array<CBUUID>,
		peripheralCallbacks: Array<(CBPeripheral, String) -> Bool>,
		serviceCallbacks: Array<(CBPeripheral, CBUUID) -> Void>,
		valueUpdatedCallbacks: Array<(CBPeripheral, CBUUID, Data) -> Void>,
		peripheralDisconnectedCallbacks: Array<(CBPeripheral) -> Void>) 
	func stopScanning()

### Windows ###
In progress

C++

	void start(const std::vector<GUID>& serviceIdsToScanFor,
		peripheralDiscoveredCb peripheralCallback,
		serviceEnumeratedCb serviceCallback,
		valueUpdatedCb valueUpdatedCallback);
	void wait();
	void stop();

### Android ###
Planned

## Version History
In development
