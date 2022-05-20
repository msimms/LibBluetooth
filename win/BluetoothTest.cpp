// BluetoothTest.cpp : This file contains the 'main' function. Program execution begins and ends there.
//

#include <iostream>
#include "BluetoothScanner.h"

bool peripheralDiscovered(GUID*)
{
    return true;
}

void serviceDiscovered(GUID* serviceid)
{
}

void valueUpdated(GUID* periperalId, GUID* serviceId, uint8_t* value)
{
}

int main()
{
    std::vector<GUID> serviceIdsToScanFor;
    BluetoothScanner scanner;

    scanner.start(serviceIdsToScanFor, peripheralDiscovered, serviceDiscovered, valueUpdated);
    scanner.wait();
    scanner.stop();
}
