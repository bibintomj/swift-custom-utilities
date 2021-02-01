//
//  SessionManager.swift
//  Quickerala
//
//  Created by Bibin on 10/06/19.
//  Copyright © 2019 Hifx IT & Media Services Private Limited. All rights reserved.
//

import UIKit

extension Session {
    static func getToken(_ completion: @escaping (Session.Token?) -> Void) {
        
        let presentLogin = {
            /// Present Login Screen
            executeInMainThread {
                CActivityIndicator.forceHide()
                UIViewController.top?.presentLogin { (loginStatus) in
                    if loginStatus == .authenticated { completion(Session.token)
                    } else { completion(nil) }
                }
            }
        }
        
        if !Session.exists { presentLogin() }  // Never Logged in
        else if Session.isExpired {     // Logged in; But token expired.
            Session.refresh { (status) in
                guard status == .refreshed else {
                    Log.error("Failed to acquire Refresh-Token via session refresh.")
                    Log.error("Attempting Reset and Login")
                    Session.reset()
                    LoggedIn.User.reset()
                    presentLogin()
                    return
                }
                completion(Session.token)
            }
        } else { completion(Session.token) }
    }
}
