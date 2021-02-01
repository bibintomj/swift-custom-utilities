//
//  File.swift
//  Quickerala
//
//  Created by Bibin on 23/08/19.
//  Copyright © 2019 Hifx IT & Media Services Private Limited. All rights reserved.
//

import Foundation

typealias Uploadable = UploadRepresentable & UploadProgressObservable & UploadOperationable & Validatable// & Equatable

class File: NSObject, UploadRepresentable, UploadProgressObservable {

    let type: MediaType
    let localUrl: URL
    let name: String
    
    var status: UploadStatus = .waiting { didSet { self.onStatusChange?(status) } }
    
    var onStatusChange: ((UploadStatus) -> Void)?
    var onProgressChange: ((_ progress: Float) -> Void)?
    var onFinishUpload: ((_ success: Bool) -> Void)?

    required init(_ type: MediaType, at localUrl: URL) {
        self.type = type
        self.localUrl = localUrl
        self.name = UUID().uuidString + String(describing: type)
    }
}

extension File: UploadOperationable {}

extension File: Validatable {
    func validate<T>(using validator: T) -> FileValidationResult where T: FileValidator {
        return validator.validate(file: self)
    }
}

extension UploadRepresentable {
    /// AWS folder name.
    var awsFolderName: String {
        switch type {
        case .logo: return PostBusiness.shared?.configuration.awsLogoFolderName ?? ""
        case .image: return PostBusiness.shared?.configuration.awsPhotoFolderName ?? ""
        case .video: return PostBusiness.shared?.configuration.awsVideoFolderName ?? ""
        case .catalogue: return PostBusiness.shared?.configuration.awsCatalogueFolderName ?? ""
        default: return PostBusiness.shared?.configuration.awsCatalogueFolderName ?? ""
        }
    }
}
