//
//  NRReachability.swift
//  NewsReader
//
//  Created by Philip Henson on 12/13/15.
//  Copyright © 2015 Phil Henson. All rights reserved.
//
//  With code adapted from http://www.brianjcoleman.com/tutorial-check-for-internet-connection-in-swift/

import Foundation
import SystemConfiguration

public class NRReachability {

    // MARK: - Class Methods
    class func isConnectedToNetwork() -> Bool {

        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)

        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, UnsafePointer($0))
        }

        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }

        let isReachable = flags == .Reachable
        let needsConnection = flags == .ConnectionRequired

        return isReachable && !needsConnection

    }
}