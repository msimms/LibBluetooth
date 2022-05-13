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
	/// List of services that we are searching for. Array is a list of service UUIDs.
	std::vector<GUID> m_serviceIdsToScanFor;

	/// Callback for when a peripheral is discovered.
	peripheralCb m_peripheralCallback;

	/// Callback for when a service is discovered.
	serviceCB m_serviceCallback;

	/// Callback for when a value is updated.
	valueCB m_valueUpdatedCallback;

private:
	void enumerateBtLeDevices();
	void scanForStandardBtDevices();

	void didDiscover(HANDLE hDevice);
	void didConnect();
};
