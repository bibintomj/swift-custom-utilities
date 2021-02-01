//
//  AWSS3Configuration.swift
//  Reporters App
//
//  Created by sijo on 02/01/20.
//  Copyright © 2020 Hifx. All rights reserved.
//

import AWSS3

protocol AWSS3Configuration: AWSService {
    var bucket: String { get }
    var cognito: AWSCognitoSessionable { get }
}

extension AWSS3Configuration {
    var region: AWSRegionType { cognito.region }
    var transferKey: String { AWS.S3.transferKey }
    var transferUtilityConfiguration: AWSS3TransferUtilityConfiguration? {
        let transferUtilityConfiguration = AWSS3TransferUtilityConfiguration()
        transferUtilityConfiguration.bucket = bucket
        return transferUtilityConfiguration
    }
    
    func register() {
        //Register a transfer utility object asynchronously
        AWSS3TransferUtility.register(with: cognito.serviceConfiguration!,
                                      transferUtilityConfiguration: transferUtilityConfiguration,
                                      forKey: transferKey) { error in
            guard error == nil else {
                print(#function, String(describing: error?.localizedDescription ?? ""))
                return
            }
            print(#function, "AWS Configuration_success")
        }
    }
}
