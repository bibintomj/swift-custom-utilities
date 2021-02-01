//
//  Strings.swift
//  MVVM-Architecture
//
//  Created by sijo on 08/03/19.
//  Copyright © 2019 Hifx. All rights reserved.
//

import Foundation

extension MNetwork {
    
    static let clientId               = "QuickeralaUA.7e9716a749755a95467c6f97f842e39e052d4d314"
    static let grantType              = "password"
    static let grantTypeRefresh       = "refresh_token"
    
    // Define headers.
    static let authorization     = "Authorization"
    static let contentType       = "Content-Type"
    static let bearer            = "Bearer "
    static let urlEncoded        = "application/x-www-form-urlencoded"
    static let apiRequestDetails = "X-Api-Request-Details"
    static let apiRequestLoggedIn = "X-API-REQUEST-LOGGEDIN"
    
}

extension MNetwork {
    static var ipAddress: String {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }
                
                let interface = ptr?.pointee
                let addrFamily = interface?.ifa_addr.pointee.sa_family
                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                    
                    let wifi = ["en0"]
                    let wired = ["en2", "en3", "en4"]
                    let cellular = ["pdp_ip0", "pdp_ip1", "pdp_ip2", "pdp_ip3"]
                    
                    let name: String = String(cString: (interface!.ifa_name))
                    if (wifi + wired + cellular).contains(name) {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(interface?.ifa_addr,
                                    socklen_t((interface?.ifa_addr.pointee.sa_len)!),
                                    &hostname, socklen_t(hostname.count),
                                    nil,
                                    socklen_t(0),
                                    NI_NUMERICHOST)
                        address = String(cString: hostname)
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        return address ?? ""
    }
}
