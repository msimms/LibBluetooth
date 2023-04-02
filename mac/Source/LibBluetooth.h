//
//  LibBluetooth.h
//  Created by Michael Simms on 3/28/23.
//

#ifndef __LIBBLUETOOTH__
#define __LIBBLUETOOTH__

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef bool (*PeripheralConnectedCb)(const char* description);
typedef void (*ValueUpdatedCb)(uint8_t* data);

void libbluetooth_addHrmToScanList();
void libbluetooth_addCyclingPowerToScanList();
void libbluetooth_addCyclingSpeedAndCadenceToScanList();
void libbluetooth_addCyclingRadarToScanList();
void libbluetooth_addFitnessMachineToScanList();

void libbluetooth_addPeripheralDiscoveredCallback(PeripheralConnectedCb cb);
void libbluetooth_addValueUpdatedCallback(ValueUpdatedCb cb);

uint16_t libbluetooth_decodeHeartRateReading(uint8_t* data);
uint16_t libbluetooth_decodeCyclingPowerReading(uint8_t* data);

void libbluetooth_startScanningForServices();
void libbluetooth_stopScanning();

}

#endif
