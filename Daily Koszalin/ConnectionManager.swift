//
//  ConnectionManager.swift
//  Daily Koszalin
//
//  Created by Adrian on 08.09.2016.
//  Copyright © 2016 Adrian Kubała. All rights reserved.
//

import UIKit
import SystemConfiguration

class ConnectionManager {
  static let sharedInstance = ConnectionManager()
  fileprivate init() {}
  
  func isConnectedToNetwork() -> Bool {
    var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
    zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
    zeroAddress.sin_family = sa_family_t(AF_INET)
    
//    let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
//      SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, UnsafePointer($0))
//    }
    
    let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
      $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
        SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
      }
    }
    
    var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
    if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
      return false
    }
    
    let isReachable = flags == .reachable
    let needsConnection = flags == .connectionRequired
    
    return isReachable && !needsConnection
  }
}
