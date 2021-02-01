//
//  FileValidator.swift
//  Quickerala
//
//  Created by Bibin on 19/08/19.
//  Copyright © 2019 Hifx IT & Media Services Private Limited. All rights reserved.
//

import Foundation

/// Represents the validity of a file.
///
/// - valid: All criterias are passsed for the file.
/// - invalid: File failed to meet the criteria.
enum FileValidationResult {
    case valid, invalid(reason: String)
}

/// Generalizes a file validator.
protocol FileValidator {
    func validate<T: Validatable>(file: T) -> FileValidationResult
}
