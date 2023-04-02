//
//  main.cpp
//  Created by Michael Simms on 3/29/23.
//

#include <iostream>
#include <thread>         // std::this_thread::sleep_for
#include <chrono>         // std::chrono::seconds
#include "LibBluetooth.h"

bool peripheralDiscovered(const char* description)
{
	return true;
}

void valueUpdated(uint8_t* data)
{
}

int main(int argc, const char * argv[]) {
	std::cout << "Building service list..." << std::endl;
	libbluetooth_addHrmToScanList();
	libbluetooth_addCyclingPowerToScanList();
	libbluetooth_addCyclingRadarToScanList();
	libbluetooth_addFitnessMachineToScanList();

	std::cout << "Adding callbacks..." << std::endl;
	libbluetooth_addPeripheralDiscoveredCallback(peripheralDiscovered);
	libbluetooth_addValueUpdatedCallback(valueUpdated);

	std::cout << "Scanning..." << std::endl;
	libbluetooth_startScanningForServices();
	while (true) // for illustrative purposes
	{
		std::this_thread::yield();
		std::this_thread::sleep_for(std::chrono::seconds(1));
	}

	std::cout << "Shutting down..." << std::endl;
	libbluetooth_stopScanning();
	return 0;
}
