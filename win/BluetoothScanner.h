//
//  BluetoothScanner.h
//  Created by Michael Simms on 5/7/22.
//

#pragma once

#include <Windows.h>
#include <bthledef.h>
#include <string>
#include <vector>

/// Definitions for the various callback types: peripheral discovered, service discovered, value read.
typedef bool (*PeripheralDiscoveredCb)(GUID* periperalId, const wchar_t* description, void* cb);
typedef void (*ServiceEnumeratedCb)(GUID* serviceId, void* cb);
typedef void (*ValueUpdatedCb)(GUID* periperalId, GUID* serviceId, GUID* characteristicId, uint8_t* value, void* cb);

/// Internal.
typedef struct ValueUpdatedCbParams
{
	GUID peripheralId;
	GUID serviceId;
	GUID characteristicId;
	ValueUpdatedCb cb;
	void* callbackParam;
} ValueUpdatedCbParams;

class BluetoothScanner
{
public:
	BluetoothScanner();
	virtual ~BluetoothScanner();

	void start(const std::vector<GUID>& serviceIdsToScanFor,
		PeripheralDiscoveredCb peripheralCallback,
		ServiceEnumeratedCb serviceCallback,
		ValueUpdatedCb valueUpdatedCallback,
		void* callbackParam);
	void wait();
	void stop();

private:
	/// @brief List of handles to discovered peripherals.
	std::vector<HANDLE> m_peripherals;

	/// @brief List of active event handles, i.e. running observers.
	std::vector<BLUETOOTH_GATT_EVENT_HANDLE> m_eventHandles;

	/// @brief List of services that we are searching for. Array is a list of service UUIDs.
	std::vector<GUID> m_serviceIdsToScanFor;

	/// @brief List of parameters needed for the value updated callback.
	std::vector<ValueUpdatedCbParams*> m_valueUpdatedCallbackParams;

	/// @brief Callback for when a peripheral is discovered.
	PeripheralDiscoveredCb m_peripheralCallback;

	/// @brief Callback for when a service is discovered.
	ServiceEnumeratedCb m_serviceCallback;

	/// @brief Callback for when a value is updated.
	ValueUpdatedCb m_valueUpdatedCallback;

	/// @brief Parameter that is passed when invoking the callback functions.
	void* m_callbackParam;

private:
	void enumerateBtLeDevices();
	void scanForStandardBtDevices();

	void didDiscoverDevice(HANDLE hDevice);
	void didDiscoverCharacteristic(HANDLE hDevice, PBTH_LE_GATT_SERVICE pServiceBuffer, PBTH_LE_GATT_CHARACTERISTIC pCharBuffer);
	void setupCharacteristicUpdateCallback(HANDLE hDevice, PBTH_LE_GATT_SERVICE pServiceBuffer, PBTH_LE_GATT_CHARACTERISTIC pCharBuffer);
};
