// BluetoothTest.cpp : This file contains the 'main' function. Program execution begins and ends there.
//

#include <iostream>
#include "BluetoothScanner.h"

bool peripheralDiscovered()
{
    return true;
}

void serviceDiscovered(GUID* serviceid)
{
}

void valueUpdated(GUID* periperalId, GUID* serviceId, unsigned char* value)
{
}

int main()
{
    std::vector<GUID> serviceIdsToScanFor;
    BluetoothScanner scanner;

    scanner.startScanning(serviceIdsToScanFor, peripheralDiscovered, serviceDiscovered, valueUpdated);
    scanner.stopScanning();
}
