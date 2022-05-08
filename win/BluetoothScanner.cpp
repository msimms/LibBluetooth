#include "BluetoothScanner.h"
#include <devguid.h>
#include <bthdef.h>
#include <Bluetoothleapis.h>

BluetoothScanner::BluetoothScanner()
{
}

BluetoothScanner::~BluetoothScanner()
{
}

void BluetoothScanner::startScanning()
{
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

				hr = BluetoothGATTGetCharacteristics(hDevice, pServiceBuffer, charBufferSize, pCharBuffer, &numChars, BLUETOOTH_GATT_FLAG_NONE);
			}
		}
	}
}

void BluetoothScanner::didConnect()
{
}
