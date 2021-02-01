//
//  AWSCognitoConfiguration.swift
//  Reporters App
//
//  Created by sijo on 02/01/20.
//  Copyright © 2020 Hifx. All rights reserved.
//

import AWSS3

private final class AWSDeveloperAuth: AWSCognitoCredentialsProviderHelper {
    
    override func token() -> AWSTask<NSString> {
        guard self.identityId == nil else { return AWSTask(result: nil) }
        // exec refresh if identityId is not provided
        return AWSTask<NSString>(result: nil).continueWith(block: { _ in return self.fetch }) as! AWSTask<NSString>
    }
    
    var fetch: AWSTask<NSString> {
        let source = AWSTaskCompletionSource<NSString>()
        User.refresh { (response) in
            self.identityId = response.identityId
            source.set(result: response.token as NSString)
        }
        return source.task
    }
}

public protocol AWSCognitoSessionable {
    var poolID: String { get }
    var authArn: String { get }
    var useEnhancedFlow: Bool { get }
    var identityProviderManager: AWSIdentityProviderManager? { get }
}

public extension AWSCognitoSessionable {
    var region: AWSRegionType { .APSoutheast2 }
    var useEnhancedFlow: Bool { true }
    var identityProviderManager: AWSIdentityProviderManager? { nil }
}

extension AWSCognitoSessionable {
    private var developerIdentity: AWSDeveloperAuth {
        .init(regionType: region,
              identityPoolId: poolID,
              useEnhancedFlow: useEnhancedFlow,
              identityProviderManager: identityProviderManager)
    }
    
    private var credentialProvider: AWSCognitoCredentialsProvider {
        .init(regionType: region,
              identityProvider: developerIdentity)
    }
    
    var serviceConfiguration: AWSServiceConfiguration? {
        .init(region: region,
              credentialsProvider: credentialProvider)
    }
}
