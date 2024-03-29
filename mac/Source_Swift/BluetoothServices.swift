//
//  BluetoothServices.swift
//  Created by Michael Simms on 5/3/22.
//

import Foundation

let BT_SERVICE_GENERIC_ACCESS =                Data([0x18, 0x00])
let BT_SERVICE_ALERT_NOTIFICATION =            Data([0x18, 0x11])
let BT_SERVICE_AUTOMATION_IO =                 Data([0x18, 0x15])
let BT_SERVICE_BATTERY_SERVICE =               Data([0x18, 0x0F])
let BT_SERVICE_BLOOD_PRESSURE =                Data([0x18, 0x10])
let BT_SERVICE_BODY_COMPOSITION =              Data([0x18, 0x1B])
let BT_SERVICE_BOND_MANAGEMENT =               Data([0x18, 0x1E])
let BT_SERVICE_CONTINUOUS_GLUCOSE_MONITORING = Data([0x18, 0x1F])
let BT_SERVICE_CURRENT_TIME =                  Data([0x18, 0x05])
let BT_SERVICE_CYCLING_POWER =                 Data([0x18, 0x18])
let BT_SERVICE_CYCLING_SPEED_AND_CADENCE =     Data([0x18, 0x16])
let BT_SERVICE_DEVICE_INFORMATION =            Data([0x18, 0x0A])
let BT_SERVICE_ENVIRONMENTAL_SENSING =         Data([0x18, 0x1A])
let BT_SERVICE_FITNESS_MACHINE =               Data([0x18, 0x26])
let BT_SERVICE_GENERIC_ATTRIBUTE =             Data([0x18, 0x01])
let BT_SERVICE_GLUCOSE =                       Data([0x18, 0x08])
let BT_SERVICE_HEALTH_THERMOMETER =            Data([0x18, 0x09])
let BT_SERVICE_HEART_RATE =                    Data([0x18, 0x0D])
let BT_SERVICE_HTTP_PROXY =                    Data([0x18, 0x23])
let BT_SERVICE_HUMAN_INTERFACE_DEVICE =        Data([0x18, 0x12])
let BT_SERVICE_IMMEDIATE_ALERT =               Data([0x18, 0x02])
let BT_SERVICE_INDOOR_POSITIONING =            Data([0x18, 0x21])
let BT_SERVICE_INSULING_DELIVERY =             Data([0x18, 0x3A])
let BT_SERVICE_INTERNET_PROTOCOL_SUPPORT =     Data([0x18, 0x20])
let BT_SERVICE_LINK_LOSS =                     Data([0x18, 0x03])
let BT_SERVICE_LOCATION_AND_NAVIGATION =       Data([0x18, 0x19])
let BT_SERVICE_MESH_PROVISIONING =             Data([0x18, 0x27])
let BT_SERVICE_MESH_PROXY =                    Data([0x18, 0x28])
let BT_SERVICE_NEXT_DST_CHANGE =               Data([0x18, 0x07])
let BT_SERVICE_OBJECT_TRANSFER =               Data([0x18, 0x25])
let BT_SERVICE_PHONE_ALERT_STATUS =            Data([0x18, 0x0E])
let BT_SERVICE_PULSE_OXIMETER =                Data([0x18, 0x22])
let BT_SERVICE_RECONNECTION_CONFIGURATION =    Data([0x18, 0x29])
let BT_SERVICE_REFERENCE_TIME_UPDATE =         Data([0x18, 0x06])
let BT_SERVICE_RUNNING_SPEED_AND_CADENCE =     Data([0x18, 0x14])
let BT_SERVICE_SCAN_PARAMETERS =               Data([0x18, 0x13])
let BT_SERVICE_TX_POWER =                      Data([0x18, 0x04])
let BT_SERVICE_USER_DATA =                     Data([0x18, 0x1C])
let BT_SERVICE_WEIGHT_SCALE =                  Data([0x18, 0x1D])
let BT_SERVICE_WEIGHT =                        Data([0x19, 0x01])

let CUSTOM_BT_SERVICE_VARIA_RADAR =            Data([0x6a, 0x4e, 0x32, 0x00, 0x66, 0x7b, 0x11, 0xe3, 0x94, 0x9a, 0x08, 0x00, 0x20, 0x0c, 0x9a, 0x66]) // Garmin Varia radar
