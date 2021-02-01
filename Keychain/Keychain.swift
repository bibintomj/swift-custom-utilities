//
//  Keychain.swift
//  ManoramaKit
//
//  Created by sijo on 12/04/19.
//  Copyright © 2019 Hifx. All rights reserved.
//

import Foundation

extension KeychainWrapper {
    
    /// Returns the session if exists.
    var session: Session.Model? {
        get {
            if let saved = data(forKey: #function) {
                let decoder = JSONDecoder()
                if let decoded = try? decoder.decode(Session.Model.self, from: saved) {
                    return decoded
                }
            }
            return nil
        }
        set {
            guard newValue != nil else {
                removeObject(forKey: #function)
                return
            }
            
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(newValue) {
                set(encoded, forKey: #function)
            }
        }
    }
    
    var someInt: Int {
        get {
            return integer(forKey: #function)
        }
        set {
            set(newValue, forKey: #function)
        }
    }
}
