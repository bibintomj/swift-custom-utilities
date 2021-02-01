//
//  AWSManager.swift
//  Quickerala
//
//  Created by Bibin on 06/08/19.
//  Copyright © 2019 Hifx IT & Media Services Private Limited. All rights reserved.
//

import AWSCore
import AWSCognito
import AWSS3

final class AWSManager {
    struct Cognito {}
    /// This configurd the AWS. Call this once in didFinishLaunchingWithOptions
    static func configure() {
        
//        AWSS3TransferManager.register(with: Cognito.serviceConfiguration, forKey: Cognito.serviceClientKey)
        AWSServiceManager.default().defaultServiceConfiguration = Cognito.serviceConfiguration
        AWSS3TransferUtility.register(with: Cognito.serviceConfiguration, forKey: Cognito.serviceClientKey)
        
        Cognito.credentialProvider.getIdentityId()?.continue({ (task) -> Any? in
            Log.debug("Completed AWS Identity ID fetch")
            guard task.error == nil else { Log.error(task.error ?? ""); return nil }
            Log.debug("IdentiyId = " + Cognito.credentialProvider.identityId)
            Log.debug("identityPoolId = " + Cognito.credentialProvider.identityPoolId)
            Log.debug("accessKey = " + (Cognito.credentialProvider.accessKey ?? ""))
            return nil
        })
    }
}

extension AWSManager.Cognito {
    /// Service client key
    static var serviceClientKey: String { return AWSConfig.serviceClientKey }
}

private extension AWSManager.Cognito {
    
    /// Region of AWS Identity Pool & Bucket
    static var region: AWSRegionType { return .euWest1 }
    
    /// Cognito pool identifier
    static var accountId: String { return AWSConfig.accountId }
    
    /// Cognito pool identifier
    static var identityPoolId: String { return AWSConfig.identityPoolId }
    
    /// Amazon Resource Name
    ///
    /// - authenticated: The role ARN to use when getting credentials for unauthenticated identities.
    /// - unauthenticated: The role ARN to use when getting credentials for authenticated identities.
    struct ARN {
        static let authenticated = AWSConfig.authARN,
        unauthenticated = AWSConfig.unauthARN
    }
    
    /// Custom identity Provider
    static var identityProvider: AWSManager.CustomIdentityProvider {
        return AWSManager.CustomIdentityProvider.shared
    }
    
    /// Credential Provider
    static var credentialProvider: AWSCognitoCredentialsProvider {
        return .init(regionType: region,
                     identityProvider: identityProvider,
                     unauthRoleArn: ARN.unauthenticated,
                     authRoleArn: ARN.authenticated)
    }
    
    /// Service Configuration
    static var serviceConfiguration: AWSServiceConfiguration {
        return .init(region: region, credentialsProvider: credentialProvider)
    }
}

private extension AWSManager {
    final class CustomIdentityProvider: AWSAbstractIdentityProvider {
        
        private static let _shared = CustomIdentityProvider()
        static var shared: CustomIdentityProvider { return _shared }
        
        private override init() {}
        
        override var accountId: String! { return AWSConfig.accountId }

        override var identityPoolId: String! { return AWSConfig.identityPoolId }
        
        override func getIdentityId() -> AWSTask<AnyObject>! {
            return AWSTask<AnyObject>(result: nil).continue({ _ -> Any? in
                return self.refresh()
            })
        }
        
        private var _token: String = ""
        override var token: String! {
            get { return _token }
            set { _token = newValue }
        }
        
        var _logins: [AnyHashable: Any]? = AWSConfig.identityProviderLogins
        override var logins: [AnyHashable: Any]? {
            get { return _logins }
            set { _logins = newValue }
        }
        
        override func refresh() -> AWSTask<AnyObject>! {
            let source = AWSTaskCompletionSource<AnyObject>.init()
            MNetwork.initiateRemoteRequest(with: AWSConfig.AWSTokenEndPoint()) { (result: Result<[String: String], MError>) in
                switch result {
                case .success(let result):
                    self.identityId = result["identity"] ?? ""
                    self.token = result["token"] ?? ""
                case .failure(let error): Log.error(error.localizedDescription)
                }
                source.setResult(true as AnyObject)
            }
            return source.task
        }
        
    }
}
