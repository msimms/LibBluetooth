//
//  BluetoothTest.cpp : This file contains the 'main' function. Program execution begins and ends there.
//  Created by Michael Simms on 5/5/22.
//

#include <iostream>
#include "BluetoothScanner.h"

bool peripheralDiscovered(GUID* peripheralId, const wchar_t* description, void* cb)
{
    wprintf(L"Peripheral discovered: %ls\n", description);
    return true;
}

void serviceDiscovered(GUID* serviceid, void* cb)
{
    printf("Service discovered.\n");
}

void valueUpdated(GUID* periperalId, GUID* serviceId, GUID* characteristicId, uint8_t* value, void* cb)
{
    printf("Value updated.\n");
}

int main()
{
    std::vector<GUID> serviceIdsToScanFor;
    BluetoothScanner scanner;

    scanner.start(serviceIdsToScanFor, peripheralDiscovered, serviceDiscovered, valueUpdated, NULL);
    scanner.wait();
    scanner.stop();
}
