//
//  Uploadable.swift
//  Quickerala
//
//  Created by Bibin on 23/08/19.
//  Copyright © 2019 Hifx IT & Media Services Private Limited. All rights reserved.
//

import Foundation
import MobileCoreServices

/// A General protocol for an item to upload to AWS.
protocol UploadRepresentable: class {
    
    /// Raw type of file. (eg. image/ video/ catalogue).
    var type: MediaType { get }
    
    /// The URL path where the file resides on device.
    var localUrl: URL { get }

    /// Name of the File
    var name: String { get }

    /// Extention of the file. (eg. mp4/pdf/jpeg).
    var `extension`: String { get }

    /// mime type of file. (eg. "image/jpeg" / "video/mp4" / "application/pdf").
    var mimeType: String { get }
    
    /// Stream of data of file.
    var data: Data { get }
}

extension UploadRepresentable {
    var `extension`: String { return localUrl.pathExtension.lowercased() }
    var mimeType: String { return localUrl.mimeType }
    var data: Data { return (try? .init(contentsOf: localUrl)) ?? .init() }
    var fullName: String { return self.name + "." + self.extension }
}

/// Representes the upload status of a file.
enum UploadStatus {
    case waiting, uploading, cancelled, failed(reason: String), completed
}

protocol UploadProgressObservable: class {
    
    /// current status of file. (eg. waiting, uploading, completed)
    var status: UploadStatus { get set }
    
    /// Callback when there is change isn upload status.
    var onStatusChange: ((UploadStatus) -> Void)? { get set }
    
    /// Callback when there is a change in upload progress.
    var onProgressChange: ((_ progress: Float) -> Void)? { get set }
    
    /// Call back when upload is completed
    var onFinishUpload: ((_ success: Bool) -> Void)? { get set }
    
}

private extension URL {
    /// Default implementation of Mime type. Determines MimeType from inbuit system Functions.
    var mimeType: String {
        let defaultMime = "application/octet-stream"
        guard let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,
                                                              pathExtension as NSString, nil)?.takeRetainedValue() else {
            return defaultMime
        }
        guard let mime = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() else {
            return defaultMime
        }
        return mime as String
    }
}
