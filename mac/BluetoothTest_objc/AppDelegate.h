//
//  AppDelegate.h
//  Created by Michael Simms on 5/9/22.
//

#import <Cocoa/Cocoa.h>
#import "BluetoothScanner.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
	BluetoothScanner* scanner;
}

@end

