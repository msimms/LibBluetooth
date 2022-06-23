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

void serviceDiscovered(GUID* serviceId, void* cb)
{
    wchar_t szGuidW[40] = { 0 };
    StringFromGUID2(*serviceId, szGuidW, sizeof(szGuidW) / sizeof(wchar_t));
    wprintf(L"Service discovered: %ws\n", szGuidW);
}

void valueUpdated(GUID* periperalId, GUID* serviceId, GUID* characteristicId, uint8_t* value, void* cb)
{
    wchar_t szGuidW[40] = { 0 };
    StringFromGUID2(*serviceId, szGuidW, sizeof(szGuidW) / sizeof(wchar_t));
    wprintf(L"Value updated for service ID: %ws\n", szGuidW);
}

int main()
{
    std::vector<GUID> serviceIdsToScanFor;
    BluetoothScanner scanner;

    printf("Starting...\n");
    scanner.start(serviceIdsToScanFor, peripheralDiscovered, serviceDiscovered, valueUpdated, NULL);
    printf("Listening...\n");
    scanner.wait();
    printf("Stopping...\n");
    scanner.stop();
}
