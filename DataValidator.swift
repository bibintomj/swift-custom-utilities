//
//  DataValidator.swift
//  Synapz Clinic
//
//  Created by Bibin on 12/01/21.
//  Copyright © 2021 Hifx. All rights reserved.
//

import UIKit

class Validation {
    enum Criteria: Equatable {
        case none, text, phoneNumber, email, url, onlyNumber
        case equal(String)
        case minCharacterCount(Int)
        case maxCharacterCount(Int)
        
        var description: String {
            switch self {
            case .none: return "Nothing to validate"
            case .text: return "must not be empty"
            case .phoneNumber: return "must be a valid phone number"
            case .email: return "must be a valid email"
            case .url: return "must be a valid URL"
            case .onlyNumber: return "must be number only"
            case .equal: return "must be matching"
            case .minCharacterCount(let count): return "must be minimum \(count) characters"
            case .maxCharacterCount(let count): return "must be under \(count) characters"
            }
        }
    }
    
    enum Result: Equatable {
        case valid, invalid( _ failedCriteria: Criteria)
        
        static func == (lhs: Validation.Result, rhs: Validation.Result) -> Bool {
            switch (lhs, rhs) {
            case (let .invalid(a1), let .invalid(a2)):
                return a1 == a2
            case (.valid, .valid): return true
            default: return false
            }
        }
    }
}

extension String {
    func validate(with criteria: Validation.Criteria) -> Validation.Result {
        switch criteria {
        case .none: return .valid
        case .text: return self.trimmed.isEmpty ? .invalid(criteria) : .valid
        case .phoneNumber: return self.isValidContact ? .valid : .invalid(criteria)
        case .email: return self.isEmail ? .valid : .invalid(criteria)
        case .url: return self.isURL ? .valid : .invalid(criteria)
        case .equal(let textToMatch): return self == textToMatch ? .valid : .invalid(criteria)
        case .minCharacterCount(let count): return self.trimmed.count >= count ? .valid : .invalid(criteria)
        case .maxCharacterCount(let count): return self.trimmed.count <= count ? .valid : .invalid(criteria)
        case .onlyNumber: return Int(self) != nil ? .valid : .invalid(criteria)
        }
    }
}

extension Array where Element == [UITextField: [Validation.Criteria]] {
    
    /// This function will validate, set error text, scroll to the view, shake the invalid data textfield.
    /// - Parameter scrollView: The ScrollView oblect, in which the texfields are in. This will used to scroll to the object if validation failed.
    func validate(containerScrollView: UIScrollView?) -> Bool {
        var validated = true
        
        self.forEach { item in
            guard let map = item.first else { return }
            map.value.forEach { criteria in
                guard validated != false else {
                    // Validation failed in previous loop. Early Exit.
                    return
                }
                guard let validationResult = map.key.text?.validate(with: criteria) else {
                    validated = false
                    return
                }
                if case .invalid(let failedCriteria) = validationResult {
                    containerScrollView?.scrollRectToVisible(map.key.frame, animated: true)
                    executeInMainThread(0.4) { map.key.shake() }
//                    map.key.errorMessage = "\(failedCriteria.description)"
                    Log.debug("Validation Failed for \(map.key.text ?? "") | Criteria \(failedCriteria)")

                    validated = false
                } else if validationResult == .valid {
//                    map.key.errorMessage = nil
                    validated = validated && true
                }
            }
        }
        
        return validated
    }
}
