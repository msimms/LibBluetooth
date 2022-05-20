#pragma once

#include <Windows.h>
#include <bthledef.h>
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
	/// List of active event handles, i.e. running observers.
	std::vector<BLUETOOTH_GATT_EVENT_HANDLE> m_eventHandles;

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

	void didDiscoverDevice(HANDLE hDevice);
	void didDiscoverCharacteristic(HANDLE hDevice, PBTH_LE_GATT_CHARACTERISTIC pCharBuffer);
	void setupCharacteristicUpdateCallback(HANDLE hDevice, PBTH_LE_GATT_CHARACTERISTIC pCharBuffer);
};
