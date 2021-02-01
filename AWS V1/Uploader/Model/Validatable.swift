//
//  Validatable.swift
//  Quickerala
//
//  Created by Bibin on 23/08/19.
//  Copyright © 2019 Hifx IT & Media Services Private Limited. All rights reserved.
//

import Foundation

/// Implement this protocol to be validated by type FileValidator.
protocol Validatable {
    func validate<T: FileValidator>(using validator: T) -> FileValidationResult
}
