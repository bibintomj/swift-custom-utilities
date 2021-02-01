//
//  AppDelegate.swift
//  Quickerala
//
//  Created by Bibin on 16/09/19.
//  Copyright © 2019 Bibin. All rights reserved.
//

import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        ApplicationConfiguration.initialize()
        
        /// Window will be set only versions earlier than iOS 13. Since iOS 13 window will be set in SeceneDelegate.
        if #available(iOS 13, *) {} else {
            ApplicationConfiguration.configureInitialViewController(on: &window)
        }
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) { Database.save() }
    
}

@available(iOS 13.0, *)
extension AppDelegate {
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration",
                                    sessionRole: connectingSceneSession.role)
    }
}
