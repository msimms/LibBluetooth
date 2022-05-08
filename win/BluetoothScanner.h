#pragma once

#include <Windows.h>

class BluetoothScanner
{
public:
	BluetoothScanner();
	virtual ~BluetoothScanner();

	void startScanning();
	void stopScanning();

private:
	void didDiscover(HANDLE hDevice);
	void didConnect();
};
