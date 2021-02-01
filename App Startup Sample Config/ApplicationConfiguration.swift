//
//  SceneInitializer.swift
//  Quickerala
//
//  Created by Bibin on 16/09/19.
//  Copyright © 2019 Bibin. All rights reserved.
//

import Firebase
import IQKeyboardManagerSwift

/// A general class for configuring application wide changes.
final class ApplicationConfiguration {
    
    private static var reachability: Reachability!
    
    /// Use this function to initialize application configuration
    static func initialize() {
       // Crashlytics.sharedInstance().crash()
        self.configureApplicationSettings()
        self.configureUISettings()
        self.configureNetworkObserver()
    }
    
    /// Use this function will setup the initial Viewcontroller.
    static func configureInitialViewController(on window: inout UIWindow?) {
        window = UIWindow(frame: UIScreen.main.bounds)
        let splashScreen = SplashViewController.instantiate()
        window?.rootViewController = InteractiveNavigationController(rootViewController: splashScreen)
        window?.makeKeyAndVisible()
    }
}

private extension ApplicationConfiguration {
    
    /// Use this function to setup the initial setting of the app.
    static func configureApplicationSettings() {
        Deployment.environment = .staging
        Request.configure()
        Database.configure()
        UserDefaults.standard.isInitialAppLaunch ? Session.reset() : Session.restore()
        UserDefaults.standard.isInitialAppLaunch ? LoggedIn.User.reset() : LoggedIn.User.restore()
        UserDefaults.standard.isInitialAppLaunch = false
        AWSManager.configure()
        FirebaseApp.configure()
        IQKeyboardManager.shared.enable = true
    }
    
    /// use this function to configure overall UI of application.
    static func configureUISettings() {
        var barTintColor = UIColor.white
        var labelColor = UIColor.black
        if #available(iOS 13, *) {
            barTintColor = .secondarySystemGroupedBackground
            labelColor = .label
        }
            
        UINavigationBar.appearance().barTintColor = barTintColor
        UINavigationBar.appearance().tintColor = labelColor
        
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: labelColor, .font: UIFont.boldTitle.withSize(17)]
        UINavigationBar.appearance().shadowImage = .init()

        if #available(iOS 13.0, *) {
            executeInMainThread(2) {
                UserInterfaceStyleManager.set(style: UserInterfaceStyleManager.currentStyle, animated: false)
            }
        }
    }
    
    /// Adds an observer to monitor network changes.
    static func configureNetworkObserver() {
        reachability = try? Reachability()
        reachability.connection == .none ? CNotificationView.show(with: "No connection") : ()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reachabilityChanged(notification:)),
                                               name: .reachabilityChanged,
                                               object: reachability)
        do { try reachability.startNotifier()
        } catch { Log.error("could not start reachability notifier") }
    }
    
    /// Adds an observer to monitor network changes.
    @objc static func reachabilityChanged(notification: Notification) {
        let reachability = notification.object as! Reachability
        switch reachability.connection {
        case .none:             CNotificationView.show(with: "No connection")
        case .wifi, .cellular:  CNotificationView.dismiss(with: "Back Online")
        }
    }
    
}
