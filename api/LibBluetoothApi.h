//
//  LibBluetoothApi.h
//  LibBluetooth_objc
//
//  Created by Michael Simms on 5/20/22.
//

#ifndef LibBluetoothApi_h
#define LibBluetoothApi_h

#include <stdint.h>

/// @brief Definitions for the various callback types: peripheral discovered, service discovered, value updated.
typedef void (*btPeripheralDiscoveredCb)(const char** peripheralId, const char* description);
typedef void (*btServiceEnumeratedCB)(const char** serviceId);
typedef void (*btValueUpdatedCB)(const char** peripheralObj, const char* serviceId, uint8_t* value);

/// @brief Initiates the scanning process. Events are reported through the various callbacks.
void startScanningForBtDevices(void);

/// @brief Terminates the scanning process.
void stopScanningForBtDevices(void);

/// @brief Simple parser, returns the power value.
uint16_t parseBtValueForScalar(uint8_t* data);

/// @brief More complex parser, returns all available data as a JSON string.
char* parseBtValueToJson(uint8_t* data);

#endif /* LibBluetoothApi_h */
