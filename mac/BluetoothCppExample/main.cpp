//
//  main.cpp
//  Created by Michael Simms on 3/29/23.
//

#include <iostream>
#include "LibBluetooth.h"

int main(int argc, const char * argv[]) {
	libbluetooth_addHrmToScanList();
	libbluetooth_startScanningForServices();
	libbluetooth_stopScanning();
	return 0;
}
