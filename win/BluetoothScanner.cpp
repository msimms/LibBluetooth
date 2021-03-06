//
//  BluetoothScanner.cpp
//  Created by Michael Simms on 5/7/22.
//

#include "BluetoothScanner.h"
#include <devguid.h>
#include <bthdef.h>
#include <bthsdpdef.h>
#include <Bluetoothleapis.h>
#include <bluetoothapis.h>
#include <SetupAPI.h>

BluetoothScanner::BluetoothScanner()
{
	m_peripheralCallback = NULL;
	m_serviceCallback = NULL;
	m_valueUpdatedCallback = NULL;
}

BluetoothScanner::~BluetoothScanner()
{
}

/// <summary>
/// This method only works for regular, i.e. not BTLE, devices.
/// </summary>
void BluetoothScanner::scanForStandardBtDevices()
{
	while (TRUE)
	{
		BLUETOOTH_FIND_RADIO_PARAMS radioFindParams;
		radioFindParams.dwSize = sizeof(BLUETOOTH_FIND_RADIO_PARAMS);

		HANDLE hRadio = NULL;
		HBLUETOOTH_RADIO_FIND hBtRadioFind = BluetoothFindFirstRadio(&radioFindParams, &hRadio);
		if (hBtRadioFind)
		{
			do
			{
				BLUETOOTH_RADIO_INFO radioInfo;
				ZeroMemory(&radioInfo, sizeof(BLUETOOTH_RADIO_INFO));
				radioInfo.dwSize = sizeof(BLUETOOTH_RADIO_INFO);

				DWORD ret = BluetoothGetRadioInfo(hRadio, &radioInfo);
				if (ret == ERROR_SUCCESS)
				{
					BLUETOOTH_DEVICE_SEARCH_PARAMS searchParams;
					ZeroMemory(&searchParams, sizeof(BLUETOOTH_DEVICE_SEARCH_PARAMS));
					searchParams.dwSize = sizeof(BLUETOOTH_DEVICE_SEARCH_PARAMS);
					searchParams.fReturnAuthenticated = TRUE;
					searchParams.fReturnConnected = TRUE;
					searchParams.fReturnRemembered = TRUE;
					searchParams.fReturnUnknown = TRUE;
					searchParams.fIssueInquiry = TRUE;
					searchParams.cTimeoutMultiplier = 15;
					searchParams.hRadio = hRadio;

					BLUETOOTH_DEVICE_INFO deviceInfo;
					ZeroMemory(&deviceInfo, sizeof(BLUETOOTH_DEVICE_INFO));
					deviceInfo.dwSize = sizeof(BLUETOOTH_DEVICE_INFO);

					HBLUETOOTH_DEVICE_FIND hBthDeviceFind = BluetoothFindFirstDevice(&searchParams, &deviceInfo);
					if (hBthDeviceFind)
					{
						do
						{
						} while (BluetoothFindNextDevice(hBthDeviceFind, &deviceInfo));

						BluetoothFindDeviceClose(hBthDeviceFind);
					}
				}

				CloseHandle(hRadio);
				hRadio = NULL;
			} while (BluetoothFindNextRadio(hBtRadioFind, &hRadio));

			BluetoothFindRadioClose(hBtRadioFind);
		}
	}
}

/// <summary>
/// Enumerates Bluetooth Low-Energy devices. Microsoft does not provide an interface for discovery,
/// so this will only return devices that have already been paired.
/// </summary>
void BluetoothScanner::enumerateBtLeDevices()
{
	GUID btLeInterfaceGuid = GUID_BLUETOOTH_GATT_SERVICE_DEVICE_INTERFACE;
	HDEVINFO hDeviceInterface = SetupDiGetClassDevs(&btLeInterfaceGuid, NULL, NULL, DIGCF_DEVICEINTERFACE | DIGCF_PRESENT);

	if (hDeviceInterface)
	{
		SP_DEVICE_INTERFACE_DATA devIfaceData;
		ZeroMemory(&devIfaceData, sizeof(SP_DEVICE_INTERFACE_DATA));
		devIfaceData.cbSize = sizeof(SP_DEVICE_INTERFACE_DATA);

		DWORD deviceInterfaceIndex = 0;
		while (SetupDiEnumDeviceInterfaces(hDeviceInterface, NULL, &btLeInterfaceGuid, deviceInterfaceIndex++, &devIfaceData))
		{
			SP_DEVICE_INTERFACE_DETAIL_DATA devInterfaceDetailData;
			ZeroMemory(&devInterfaceDetailData, sizeof(SP_DEVICE_INTERFACE_DETAIL_DATA));
			devInterfaceDetailData.cbSize = sizeof(SP_DEVICE_INTERFACE_DETAIL_DATA);

			// Query for the buffer size.
			DWORD size = 0;
			if (!SetupDiGetDeviceInterfaceDetail(hDeviceInterface, &devIfaceData, NULL, 0, &size, NULL))
			{
				if (GetLastError() == ERROR_INSUFFICIENT_BUFFER)
				{
					// Allocate a buffer of the specified size and call the function again.
					PSP_DEVICE_INTERFACE_DETAIL_DATA pDeviceInterfaceDetailData = (PSP_DEVICE_INTERFACE_DETAIL_DATA)GlobalAlloc(GPTR, size);
					if (pDeviceInterfaceDetailData)
					{
						ZeroMemory(pDeviceInterfaceDetailData, sizeof(SP_DEVICE_INTERFACE_DETAIL_DATA));
						pDeviceInterfaceDetailData->cbSize = sizeof(SP_DEVICE_INTERFACE_DETAIL_DATA);

						SP_DEVINFO_DATA devInfoData;
						ZeroMemory(&devInfoData, sizeof(SP_DEVINFO_DATA));
						devInfoData.cbSize = sizeof(SP_DEVINFO_DATA);

						if (SetupDiGetDeviceInterfaceDetail(hDeviceInterface, &devIfaceData, pDeviceInterfaceDetailData, size, &size, &devInfoData))
						{
							HANDLE deviceHandle = CreateFile(pDeviceInterfaceDetailData->DevicePath, GENERIC_READ | GENERIC_WRITE, FILE_SHARE_READ | FILE_SHARE_WRITE, NULL, OPEN_EXISTING, 0, NULL);
							if (deviceHandle)
							{
								// Call the peripheral discovered callback and continue if it returns TRUE.
								if (this->m_peripheralCallback(NULL, pDeviceInterfaceDetailData->DevicePath, this->m_callbackParam))
								{
									didDiscoverDevice(deviceHandle);
								}

								m_peripherals.push_back(deviceHandle);
							}
						}

						GlobalFree(pDeviceInterfaceDetailData);
					}
				}
			}
		}

		SetupDiDestroyDeviceInfoList(hDeviceInterface);
	}
}

void BluetoothScanner::didDiscoverDevice(HANDLE hDevice)
{
	USHORT serviceBufferCount = 0;

	// How much memory do we need to store the service descriptor list?
	HRESULT hr = BluetoothGATTGetServices(hDevice, 0, NULL, &serviceBufferCount, BLUETOOTH_GATT_FLAG_NONE);

	// Previous call was to determine how much memory we need to store the service list.
	if (hr == HRESULT_FROM_WIN32(ERROR_MORE_DATA) && serviceBufferCount > 0)
	{
		// Allocate memory for the service descriptions.
		PBTH_LE_GATT_SERVICE pServiceBuffer = (PBTH_LE_GATT_SERVICE)GlobalAlloc(GPTR, sizeof(BTH_LE_GATT_SERVICE) * serviceBufferCount);
		if (pServiceBuffer)
		{
			RtlZeroMemory(pServiceBuffer, sizeof(BTH_LE_GATT_SERVICE) * serviceBufferCount);

			// Read the service list.
			USHORT numServices = 0;
			hr = BluetoothGATTGetServices(hDevice, serviceBufferCount, pServiceBuffer, &numServices, BLUETOOTH_GATT_FLAG_NONE);
			if (hr == S_OK)
			{
				// For each service that was returned....
				for (USHORT serviceBufferIndex = 0; serviceBufferIndex < serviceBufferCount; ++serviceBufferIndex)
				{
					// Buffer offset.
					BTH_LE_GATT_SERVICE* pCurrentServiceBuffer = pServiceBuffer + serviceBufferIndex;

					// Trigger the callback to let the caller know that we found a service.
					this->m_serviceCallback(&pCurrentServiceBuffer->ServiceUuid.Value.LongUuid, this->m_callbackParam);

					// How much memory do we need to store the characteristics?
					USHORT numCharacteristics = 0;
					hr = BluetoothGATTGetCharacteristics(hDevice, pCurrentServiceBuffer, 0, NULL, &numCharacteristics, BLUETOOTH_GATT_FLAG_NONE);

					// Previous call was to determine how much memory we need to store the characteristics.
					if (hr == HRESULT_FROM_WIN32(ERROR_MORE_DATA) && numCharacteristics > 0)
					{
						// Allocate memory for the characteristic descriptions.
						SIZE_T charBufferSize = numCharacteristics * sizeof(BTH_LE_GATT_CHARACTERISTIC);
						PBTH_LE_GATT_CHARACTERISTIC pCharBuffer = (PBTH_LE_GATT_CHARACTERISTIC)GlobalAlloc(GPTR, charBufferSize);
						if (pCharBuffer)
						{
							RtlZeroMemory(pCharBuffer, charBufferSize);
							
							// Read the characteristics.
							hr = BluetoothGATTGetCharacteristics(hDevice, pCurrentServiceBuffer, numCharacteristics, pCharBuffer, &numCharacteristics, BLUETOOTH_GATT_FLAG_NONE);
							if (hr == S_OK)
							{
								// For each characteristic....
								for (USHORT characteristicIndex = 0; characteristicIndex < numCharacteristics; ++characteristicIndex)
								{
									// Buffer offset.
									PBTH_LE_GATT_CHARACTERISTIC pCurrentCharBuffer = pCharBuffer + characteristicIndex;

									// Process the characteristics.
									didDiscoverCharacteristic(hDevice, pCurrentServiceBuffer, pCurrentCharBuffer);
								}
							}

							GlobalFree(pCharBuffer);
						}
					}
				}
			}

			GlobalFree(pServiceBuffer);
		}
	}
}

void BluetoothScanner::didDiscoverCharacteristic(HANDLE hDevice, PBTH_LE_GATT_SERVICE pServiceBuffer, PBTH_LE_GATT_CHARACTERISTIC pCharBuffer)
{
	// How much memory do we need to store the descriptors?
	USHORT numDescriptors = 0;
	HRESULT hr = BluetoothGATTGetDescriptors(hDevice, pCharBuffer, 0, NULL, &numDescriptors, BLUETOOTH_GATT_FLAG_NONE);

	// Previous call was to determine how much memory we need to store the descriptors.
	if (hr == HRESULT_FROM_WIN32(ERROR_MORE_DATA) && numDescriptors > 0)
	{
		// Allocate memory for the characteristic descriptors.
		SIZE_T descriptorBufferSize = numDescriptors * sizeof(BTH_LE_GATT_DESCRIPTOR);
		PBTH_LE_GATT_DESCRIPTOR pDescriptorBuffer = (PBTH_LE_GATT_DESCRIPTOR)GlobalAlloc(GPTR, descriptorBufferSize);
		if (pDescriptorBuffer)
		{
			RtlZeroMemory(pDescriptorBuffer, descriptorBufferSize);

			// Read the descriptors.
			hr = BluetoothGATTGetDescriptors(hDevice, pCharBuffer, numDescriptors, pDescriptorBuffer, &numDescriptors, BLUETOOTH_GATT_FLAG_NONE);
			if (hr == S_OK)
			{
				// For each descriptor.
				for (USHORT descriptorIndex = 0; descriptorIndex < numDescriptors; ++descriptorIndex)
				{
					// Buffer offset.
					PBTH_LE_GATT_DESCRIPTOR pCurrentDescriptorBuffer = pDescriptorBuffer + descriptorIndex;

					// How much memory do we need to store the value?
					USHORT valueBufferSize = 0;
					hr = BluetoothGATTGetDescriptorValue(hDevice, pCurrentDescriptorBuffer, 0, NULL, &valueBufferSize, BLUETOOTH_GATT_FLAG_NONE);

					// Previous call was to determine how much memory we need to store the value.
					if (hr == HRESULT_FROM_WIN32(ERROR_MORE_DATA) && valueBufferSize > 0)
					{
						PBTH_LE_GATT_DESCRIPTOR_VALUE pValueBuffer = (PBTH_LE_GATT_DESCRIPTOR_VALUE)GlobalAlloc(GPTR, valueBufferSize);

						if (pValueBuffer)
						{
							RtlZeroMemory(pValueBuffer, valueBufferSize);

							// Read the descriptor value.
							hr = BluetoothGATTGetDescriptorValue(hDevice, pCurrentDescriptorBuffer, valueBufferSize, pValueBuffer, NULL, BLUETOOTH_GATT_FLAG_NONE);

							// Trigger the callback.
							setupCharacteristicUpdateCallback(hDevice, pServiceBuffer, pCharBuffer);

							// Free the memory used to read the value.
							GlobalFree(pValueBuffer);
						}
					}
				}
			}

			GlobalFree(pDescriptorBuffer);
		}
	}
}

VOID CALLBACK valueUpdated(BTH_LE_GATT_EVENT_TYPE EventType, PVOID EventOutParameter, PVOID Context)
{
	ValueUpdatedCbParams* params = (ValueUpdatedCbParams*)Context;
	PBLUETOOTH_GATT_VALUE_CHANGED_EVENT valueChangedEventParams = (PBLUETOOTH_GATT_VALUE_CHANGED_EVENT)EventOutParameter;

	if (valueChangedEventParams->CharacteristicValue->DataSize > 0)
	{
		params->cb(NULL, &params->serviceId, &params->characteristicId, valueChangedEventParams->CharacteristicValue->Data, params->callbackParam);
	}
}

void BluetoothScanner::setupCharacteristicUpdateCallback(HANDLE hDevice, PBTH_LE_GATT_SERVICE pServiceBuffer, PBTH_LE_GATT_CHARACTERISTIC pCharBuffer)
{
	if (pCharBuffer->IsNotifiable)
	{
		BLUETOOTH_GATT_EVENT_HANDLE eventHandle = NULL;
		BLUETOOTH_GATT_VALUE_CHANGED_EVENT_REGISTRATION eventParam;

		eventParam.Characteristics[0] = *pCharBuffer;
		eventParam.NumCharacteristics = 1;

		ValueUpdatedCbParams* params = new ValueUpdatedCbParams;
		params->serviceId = pServiceBuffer->ServiceUuid.Value.LongUuid;
		params->characteristicId = pCharBuffer->CharacteristicUuid.Value.LongUuid;
		params->cb = m_valueUpdatedCallback;
		params->callbackParam = this->m_callbackParam;
		m_valueUpdatedCallbackParams.push_back(params);

		HRESULT hr = BluetoothGATTRegisterEvent(hDevice, CharacteristicValueChangedEvent, &eventParam, valueUpdated,
			(PVOID)params, &eventHandle, BLUETOOTH_GATT_FLAG_NONE);
		if (hr == S_OK)
		{
			m_eventHandles.push_back(eventHandle);
		}
	}

	if (pCharBuffer->IsReadable)
	{
		// How much memory do we need?
		USHORT charValueDataSize = 0;
		HRESULT hr = BluetoothGATTGetCharacteristicValue(hDevice, pCharBuffer, 0, NULL, &charValueDataSize, BLUETOOTH_GATT_FLAG_NONE);
		if (hr == HRESULT_FROM_WIN32(ERROR_MORE_DATA) && charValueDataSize > 0)
		{
			// Previous call was to determine how much memory we need to store the value.
			PBTH_LE_GATT_CHARACTERISTIC_VALUE pCharValueBuffer = (PBTH_LE_GATT_CHARACTERISTIC_VALUE)GlobalAlloc(GPTR, charValueDataSize);
			if (pCharValueBuffer)
			{
				// Read the value.
				hr = BluetoothGATTGetCharacteristicValue(hDevice, pCharBuffer, 0, pCharValueBuffer, &charValueDataSize, BLUETOOTH_GATT_FLAG_NONE);
				if (hr == S_OK)
				{
					m_valueUpdatedCallback(NULL, &pServiceBuffer->ServiceUuid.Value.LongUuid, &pCharBuffer->CharacteristicUuid.Value.LongUuid, pCharValueBuffer->Data, this->m_callbackParam);
				}

				GlobalFree(pCharValueBuffer);
			}
		}
	}
}

void BluetoothScanner::start(const std::vector<GUID>& serviceIdsToScanFor,
	PeripheralDiscoveredCb peripheralCallback,
	ServiceEnumeratedCb serviceCallback,
	ValueUpdatedCb valueUpdatedCallback,
	void* callbackParam)
{
	m_serviceIdsToScanFor = serviceIdsToScanFor;
	m_peripheralCallback = peripheralCallback;
	m_serviceCallback = serviceCallback;
	m_valueUpdatedCallback = valueUpdatedCallback;
	m_callbackParam = callbackParam;

	enumerateBtLeDevices();
}

void BluetoothScanner::wait()
{
	while (TRUE)
	{
		Sleep(1000);
	}
}

void BluetoothScanner::stop()
{
	for (auto params = m_valueUpdatedCallbackParams.begin(); params != m_valueUpdatedCallbackParams.end(); ++params)
	{
		delete (*params);
	}
	m_valueUpdatedCallbackParams.clear();

	for (auto handle = m_eventHandles.begin(); handle != m_eventHandles.end(); ++handle)
	{
		BluetoothGATTUnregisterEvent((*handle), BLUETOOTH_GATT_FLAG_NONE);
		CloseHandle((*handle));
	}
	m_eventHandles.clear();

	for (auto device = m_peripherals.begin(); device != m_peripherals.end(); ++device)
	{
		CloseHandle((*device));
	}
	m_peripherals.clear();
}
