//
//  AWSMediaValidator.swift
//  Quickerala
//
//  Created by Bibin on 19/08/19.
//  Copyright © 2019 Hifx IT & Media Services Private Limited. All rights reserved.
//

import UIKit

final class AWSFileValidator {
    private static let _shared = AWSFileValidator()
    static var shared: AWSFileValidator { return _shared }
}

extension AWSFileValidator: FileValidator {
    func validate<T>(file: T) -> FileValidationResult where T: Validatable {
        guard let fileToValidate = file as? File else { return .invalid(reason: "File is invalid.") }
        
        let fileSize = Double(fileToValidate.localUrl.fileSizeInMegaBytes)
        let maxAllowedFileSize = fileToValidate.type.maxAllowedSizeInMegaBytes
        
        guard fileSize <= maxAllowedFileSize else {
            // swiftlint:disable:next line_length
            let reason = "Maximum allowed size is \(fileToValidate.type.maxAllowedSizeString). File size is \(fileToValidate.localUrl.fileSizeString)."
            return .invalid(reason: reason)
        }
        
        // At this stage, all coomon validations are over.
        // If logo, then dimensions needs to be validated.
        guard fileToValidate.type == .logo else { return .valid }
        
        guard let imageData = try? Data(contentsOf: fileToValidate.localUrl),
            let logoImage = UIImage(data: imageData as Data) else {
            return .invalid(reason: "File is corrupted.")
        }
        
        let isValidWidth = Int(logoImage.pixelDimension.width) >= (PostBusiness.shared?.configuration.logoThumbnailWidth ?? 0)
        let isValidHeight = Int(logoImage.pixelDimension.height) >= (PostBusiness.shared?.configuration.logoThumbnailHeight ?? 0)

        guard isValidWidth, isValidHeight else {
            let currentDimensionString = "\(logoImage.pixelDimension.width) x \(logoImage.pixelDimension.height)"
            // swiftlint:disable:next line_length
            let allowedDimensionString = "\(PostBusiness.shared?.configuration.logoThumbnailWidth ?? 0) x \(PostBusiness.shared?.configuration.logoThumbnailHeight ?? 0)"
            return .invalid(reason: "Minimum allowed dimension is \(allowedDimensionString). Image dimension is \(currentDimensionString).")
        }
        
        return .valid
        
    }
}

private extension URL {
    var attributes: [FileAttributeKey: Any]? {
        do { return try FileManager.default.attributesOfItem(atPath: path)
        } catch {
            Log.error("FileAttribute error: \(error as NSError)")
        }
        return nil
    }

    var fileSizeInBytes: UInt64 { attributes?[.size] as? UInt64 ?? UInt64(0) }
    
    var fileSizeInKiloBytes: UInt64 { fileSizeInBytes / UInt64(1024) }
    
    var fileSizeInMegaBytes: UInt64 { fileSizeInKiloBytes / UInt64(1024) }

    var fileSizeString: String { ByteCountFormatter.string(fromByteCount: Int64(fileSizeInBytes), countStyle: .file) }
}

private extension MediaType {
    var maxAllowedSizeInMegaBytes: Double { maxAllowedSizeString.extractedSize }
    
    var maxAllowedSizeString: String {
        switch self {
        case .unknown: return "0 - MB"
        case .logo: return PostBusiness.shared?.configuration.maxLogoSize ?? "0 - MB"
        case .image: return PostBusiness.shared?.configuration.maxPhotoSize ?? "0 - MB"
        case .video: return PostBusiness.shared?.configuration.maxVideoSize ?? "0 - MB"
        case .catalogue: return PostBusiness.shared?.configuration.maxCatalogueSize ?? "0 - MB"
        }
    }
}

private extension String {
    var extractedSize: Double {
        let sizeString = self.components(separatedBy: " - ").first
        return Double(sizeString ?? "0") ?? 0.0
    }
}

private extension UIImage {
    var pixelDimension: (width: CGFloat, height: CGFloat) {
        let widthInPoints = size.width
        let widthInPixels = widthInPoints * scale
        
        let heightInPoints = size.height
        let heightInPixels = heightInPoints * scale
        
        return (widthInPixels, heightInPixels)
    }
}
