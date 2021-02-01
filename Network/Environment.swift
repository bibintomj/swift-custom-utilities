//
//  Environment.swift
//  ManoramaKit
//
//  Created by sijo on 10/04/19.
//  Copyright © 2019 Hifx. All rights reserved.
//

import Foundation

extension Deployment.Environment {
    private static var productionAPIHost: String { "https://api.quickerala.com" }
    private static var stagingAPIHost: String { "https://stag-api.quickerala.com" }
    
    private static var productionWebsite: String { "https://www.quickerala.com" }
    private static var stagingWebsite: String { "https://stag-fe.quickerala.com" }
}

// MARK: Public Environment Declaration
//----------------------------------------------------------------------------------------------
/// Favourable environments.
struct Deployment {
    
    enum Environment {
        
        /// Producation environment.
        case production
        /// Stage environment.
        case staging
        
        case custom(url: String)
        
        var url: String {
            switch self {
            case .production: return Deployment.Environment.productionAPIHost
            case .staging: return Deployment.Environment.stagingAPIHost
            case .custom(let url): return url
            }
        }
        
        var website: String {
            switch self {
            case .production: return Deployment.Environment.productionWebsite
            case .staging: return Deployment.Environment.stagingWebsite
            case .custom(let url): return url
            }
        }
        
        init(with url: String) {
            switch url {
            case Deployment.Environment.productionAPIHost: self = .production
            case Deployment.Environment.stagingAPIHost: self = .staging
            default: self = .custom(url: url)
            }
        }
    }
    
    /// Current Environment of the Application. 
    static var environment: Environment {
        get { return UserDefaults.standard.environment }
        set { UserDefaults.standard.environment = newValue }
    }
}
