#pragma once

#include <Windows.h>
#include <bthledef.h>
#include <string>
#include <vector>

/// Definitions for the various callback types: peripheral discovered, service discovered, value read.
typedef bool (*peripheralDiscoveredCb)(GUID*);
typedef void (*serviceEnumeratedCb)(GUID*);
typedef void (*valueUpdatedCb)(GUID*, GUID*, uint8_t*);

class BluetoothScanner
{
public:
	BluetoothScanner();
	virtual ~BluetoothScanner();

	void start(const std::vector<GUID>& serviceIdsToScanFor,
		peripheralDiscoveredCb peripheralCallback,
		serviceEnumeratedCb serviceCallback,
		valueUpdatedCb valueUpdatedCallback);
	void wait();
	void stop();

private:
	/// List of handles to discovered peripherals.
	std::vector<HANDLE> m_peripherals;

	/// List of active event handles, i.e. running observers.
	std::vector<BLUETOOTH_GATT_EVENT_HANDLE> m_eventHandles;

	/// List of services that we are searching for. Array is a list of service UUIDs.
	std::vector<GUID> m_serviceIdsToScanFor;

	/// Callback for when a peripheral is discovered.
	peripheralDiscoveredCb m_peripheralCallback;

	/// Callback for when a service is discovered.
	serviceEnumeratedCb m_serviceCallback;

	/// Callback for when a value is updated.
	valueUpdatedCb m_valueUpdatedCallback;

private:
	void enumerateBtLeDevices();
	void scanForStandardBtDevices();

	void didDiscoverDevice(HANDLE hDevice);
	void didDiscoverCharacteristic(HANDLE hDevice, PBTH_LE_GATT_CHARACTERISTIC pCharBuffer);
	void setupCharacteristicUpdateCallback(HANDLE hDevice, PBTH_LE_GATT_CHARACTERISTIC pCharBuffer);
};
