//
//  DataReader.swift
//  Created by Michael Simms on 6/17/23.
//

import Foundation

func read16(data: Data) -> UInt16 {
	return (UInt16)(data[0] << 8) | (UInt16)(data[1])
}

func read32(data: Data) -> UInt32 {
	return ((UInt32)(data[0]) << 24) | ((UInt32)(data[1]) << 16) | ((UInt32)(data[2]) << 8) | (UInt32)(data[3])
}
