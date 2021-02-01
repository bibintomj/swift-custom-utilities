//
//  AWSConfig.swift
//  General
//
//  Created by Bibin on 06/08/19.
//  Copyright © 2019 Hifx IT & Media Services Private Limited. All rights reserved.
//

import Foundation

/// User this class to specify all the AWS Configuration
struct AWSConfig {
    static var environment: Deployment.Environment { return Deployment.environment }
}

extension AWSConfig {
    
    /// Service Client ID
    static var serviceClientKey: String { return "transferKey" }
    
    /// Cognito pool identifier
    static var accountId: String { return "" }
    
    /// Cognito pool identifier
    static var identityPoolId: String {
        switch environment {
        case .staging: return ""
        case .production: return ""
        default: return ""
        }
    }
    
    /// Authenticated Amazon Resource Name
    static var authARN: String {
        switch environment {
        case .staging: return ""
        case .production: return ""
        default: return ""
        }
    }
    
    /// Unauthenticated Amazon Resource Name
    static var unauthARN: String {
        switch environment {
        case .staging: return ""
        case .production: return ""
        default: return ""
        }
    }
    
    /// Bucket Name
    static var bucketName: String {
        switch environment {
        case .staging: return ""
        case .production: return ""
        default: return ""
        }
    }
    
    /// Identity Provider Logins
    static var identityProviderLogins: [AnyHashable: Any] { return ["": ""] }
}

extension AWSConfig {
    /// Endpoint for AWS Token fetching
    struct AWSTokenEndPoint: Endpoint {
        var path: String { return "" }
        
        var httpMethod: HTTPMethod { return .get }
        
        var parameters: ParameterConstructable { return [:] }
        
        var isSessionRequired: Bool { return true }
    }
}
