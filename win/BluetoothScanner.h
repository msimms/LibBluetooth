#pragma once

#include <Windows.h>
#include <string>
#include <vector>

/// Definitions for the various callback types: peripheral discovered, service discovered, value read.
typedef bool (*peripheralCb)();
typedef void (*serviceCB)(GUID*);
typedef void (*valueCB)(GUID*, GUID*, unsigned char*);

class BluetoothScanner
{
public:
	BluetoothScanner();
	virtual ~BluetoothScanner();

	void startScanning(const std::vector<GUID>& serviceIdsToScanFor,
		peripheralCb peripheralCallback,
		serviceCB serviceCallback,
		valueCB valueUpdatedCallback);
	void stopScanning();

private:
	void enumerateBtLeDevices();
	void scanForStandardBtDevices();

	void didDiscover(HANDLE hDevice);
	void didConnect();
};
