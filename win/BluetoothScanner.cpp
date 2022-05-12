#include "BluetoothScanner.h"
#include <devguid.h>
#include <bthdef.h>
#include <bthsdpdef.h>
#include <Bluetoothleapis.h>
#include <bluetoothapis.h>

BluetoothScanner::BluetoothScanner()
{
}

BluetoothScanner::~BluetoothScanner()
{
}

void BluetoothScanner::startScanning()
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

void BluetoothScanner::stopScanning()
{
}

void BluetoothScanner::didDiscover(HANDLE hDevice)
{
	USHORT serviceBufferCount = 0;
	HRESULT hr = BluetoothGATTGetServices(hDevice, 0, NULL, &serviceBufferCount, BLUETOOTH_GATT_FLAG_NONE);
	PBTH_LE_GATT_SERVICE pServiceBuffer = (PBTH_LE_GATT_SERVICE)malloc(sizeof(BTH_LE_GATT_SERVICE) * serviceBufferCount);

	if (pServiceBuffer)
	{
		RtlZeroMemory(pServiceBuffer, sizeof(BTH_LE_GATT_SERVICE) * serviceBufferCount);

		USHORT numServices = 0;
		USHORT charBufferSize = 0;

		hr = BluetoothGATTGetServices(hDevice, serviceBufferCount, pServiceBuffer, &numServices, BLUETOOTH_GATT_FLAG_NONE);
		hr = BluetoothGATTGetCharacteristics(hDevice, pServiceBuffer, 0, NULL, &charBufferSize, BLUETOOTH_GATT_FLAG_NONE);

		if (charBufferSize > 0)
		{
			PBTH_LE_GATT_CHARACTERISTIC pCharBuffer = (PBTH_LE_GATT_CHARACTERISTIC)malloc(charBufferSize * sizeof(BTH_LE_GATT_CHARACTERISTIC));

			if (pCharBuffer)
			{
				RtlZeroMemory(pCharBuffer, charBufferSize * sizeof(BTH_LE_GATT_CHARACTERISTIC));

				USHORT numChars = 0;
				USHORT charBufferSize = 0;

				hr = BluetoothGATTGetCharacteristics(hDevice, pServiceBuffer, charBufferSize, pCharBuffer, &numChars, BLUETOOTH_GATT_FLAG_NONE);

				for (USHORT i = 0; i < charBufferSize; ++i)
				{
				}
			}
		}
	}
}

void BluetoothScanner::didConnect()
{
}
