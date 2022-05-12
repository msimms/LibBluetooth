// BluetoothTest.cpp : This file contains the 'main' function. Program execution begins and ends there.
//

#include <iostream>
#include "BluetoothScanner.h"

bool peripheralDiscovered()
{
    return true;
}

void serviceDiscovered(GUID*)
{
}

void valueUpdated(GUID*, GUID*, unsigned char*)
{
}

int main()
{
    std::vector<GUID> serviceIdsToScanFor;
    BluetoothScanner scanner;
    scanner.startScanning(serviceIdsToScanFor, peripheralDiscovered, serviceDiscovered, valueUpdated);
}
