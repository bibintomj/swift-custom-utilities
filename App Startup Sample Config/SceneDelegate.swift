//
//  SceneDelegate.swift
//  Quickerala
//
//  Created by Bibin on 16/09/19.
//  Copyright © 2019 Bibin. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        ApplicationConfiguration.configureInitialViewController(on: &window)
        window?.windowScene = windowScene
    }
    
}
