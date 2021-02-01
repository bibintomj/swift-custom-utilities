//
//  Helpers.swift
//  Quickerala
//
//  Created by Bibin on 28/05/19.
//  Copyright © 2019 Hifx IT & Media Services Private Limited. All rights reserved.
//

import Foundation

// MARK: Method to Run a block in Main thread
//----------------------------------------------------------------------------------------------
/// Dispatching to Main Queue.
/// - Parameter completion: Complete with a main queue escape.
/// - Important: Use this only for UI update operations.
func executeInMainThread(_ delay: TimeInterval = 0, _ completion: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) { completion() }
}
