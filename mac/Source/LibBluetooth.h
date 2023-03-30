//
//  LibBluetooth.h
//  Created by Michael Simms on 3/28/23.
//

#ifndef __LIBBLUETOOTH__
#define __LIBBLUETOOTH__

#ifdef __cplusplus
extern "C" {
#endif

void libbluetooth_addHrmToScanList();
void libbluetooth_addCyclingPowerToScanList();
void libbluetooth_addCyclingSpeedAndCadenceToScanList();
void libbluetooth_addCyclingRadarToScanList();
void libbluetooth_addFitnessMachineToScanList();
void libbluetooth_startScanningForServices();
void libbluetooth_stopScanning();

}

#endif
