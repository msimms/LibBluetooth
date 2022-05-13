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
	GUID btLeInterfaceGuid = GUID_BLUETOOTHLE_DEVICE_INTERFACE;
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
				DWORD err = GetLastError();

				if (err == ERROR_NO_MORE_ITEMS)
				{
					break;
				}
				if (err == ERROR_INSUFFICIENT_BUFFER)
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
							HANDLE deviceHandle = CreateFile(pDeviceInterfaceDetailData->DevicePath, GENERIC_READ, FILE_SHARE_READ | FILE_SHARE_WRITE, NULL, OPEN_EXISTING, 0, NULL);
							if (deviceHandle)
							{
								// Call the peripheral discovered callback and continue if it returns TRUE.
								if (this->m_peripheralCallback())
								{
									didDiscover(deviceHandle);
								}
								CloseHandle(deviceHandle);
							}
						}

						GlobalFree(pDeviceInterfaceDetailData);
					}
				}
			}
		}
	}
}

void BluetoothScanner::startScanning(const std::vector<GUID>& serviceIdsToScanFor,
	peripheralCb peripheralCallback,
	serviceCB serviceCallback,
	valueCB valueUpdatedCallback)
{
	m_serviceIdsToScanFor = serviceIdsToScanFor;
	m_peripheralCallback = peripheralCallback;
	m_serviceCallback = serviceCallback;
	m_valueUpdatedCallback = valueUpdatedCallback;

	enumerateBtLeDevices();
}

void BluetoothScanner::stopScanning()
{
}

void BluetoothScanner::didDiscover(HANDLE hDevice)
{
	USHORT serviceBufferCount = 0;

	// How much memory do we need to store the service list?
	HRESULT hr = BluetoothGATTGetServices(hDevice, 0, NULL, &serviceBufferCount, BLUETOOTH_GATT_FLAG_NONE);

	// Previous call was to determine how much memory we need to store the service list.
	if (serviceBufferCount > 0)
	{
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
					BTH_LE_GATT_SERVICE* pCurrentServiceBuffer = pServiceBuffer + serviceBufferIndex;

					// Trigger the callback to let the caller know that we found a service.
					this->m_serviceCallback(&pCurrentServiceBuffer->ServiceUuid.Value.LongUuid);

					// How much memory do we need to store the characteristics?
					USHORT charBufferSize = 0;
					hr = BluetoothGATTGetCharacteristics(hDevice, pCurrentServiceBuffer, 0, NULL, &charBufferSize, BLUETOOTH_GATT_FLAG_NONE);

					// Previous call was to determine how much memory we need to store the characteristics.
					if (charBufferSize > 0)
					{
						PBTH_LE_GATT_CHARACTERISTIC pCharBuffer = (PBTH_LE_GATT_CHARACTERISTIC)GlobalAlloc(GPTR, charBufferSize * sizeof(BTH_LE_GATT_CHARACTERISTIC));

						if (pCharBuffer)
						{
							RtlZeroMemory(pCharBuffer, charBufferSize * sizeof(BTH_LE_GATT_CHARACTERISTIC));

							// Read the characteristics.
							USHORT numCharacteristics = 0;
							hr = BluetoothGATTGetCharacteristics(hDevice, pServiceBuffer, charBufferSize, pCharBuffer, &numCharacteristics, BLUETOOTH_GATT_FLAG_NONE);

							if (hr == NO_ERROR)
							{
								// For each characteristic....
								for (USHORT characteristicIndex = 0; characteristicIndex < numCharacteristics; ++characteristicIndex)
								{
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

void BluetoothScanner::didConnect()
{
}
