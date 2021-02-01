//
//  AWSBasicSession.swift
//  Reporters App
//
//  Created by sijo on 04/02/20.
//  Copyright © 2020 Hifx. All rights reserved.
//

import AWSS3

protocol AWSService {
    var region: AWSRegionType { get }
    var transferKey: String { get }
    var serviceConfiguration: AWSServiceConfiguration? { get }
    var transferUtilityConfiguration: AWSS3TransferUtilityConfiguration? { get }
}

extension AWSService {
    var serviceConfiguration: AWSServiceConfiguration? { nil }
    var transferUtilityConfiguration: AWSS3TransferUtilityConfiguration? { nil }
}

protocol AWSBasicSessionable: AWSService {
    var accessKey: String { get }
    var secretKey: String { get }
    var objectKey: String { get }
    var sessionToken: String { get }
    var bucket: String { get }
    var requestURL: String? { get }
}

extension AWSBasicSessionable {
    var region: AWSRegionType { .APSoutheast2 }
    var transferKey: String { accessKey }
}

extension AWSBasicSessionable {
    var credentialProvider: AWSBasicSessionCredentialsProvider {
        .init(accessKey: accessKey,
              secretKey: secretKey,
              sessionToken: sessionToken)
    }
    
    var serviceConfiguration: AWSServiceConfiguration? {
        .init(region: region,
              credentialsProvider: credentialProvider)
    }
    
    var transferUtilityConfiguration: AWSS3TransferUtilityConfiguration? {
        let transferUtilityConfiguration = AWSS3TransferUtilityConfiguration()
        transferUtilityConfiguration.bucket = bucket
        return transferUtilityConfiguration
    }
}

extension AWSBasicSessionable {
    func register(_ completion: @escaping Completion) {
        //Register a transfer utility object asynchronously
        AWSS3TransferUtility.register(with: serviceConfiguration!,
                                      transferUtilityConfiguration: transferUtilityConfiguration,
                                      forKey: transferKey) { error in
            guard error == nil else {
                print(error?.localizedDescription ?? "AWS Configuration failed.")
                completion()
                return
            }
            print(#function, "AWS Configuration success.")
            completion()
        }
    }
}
