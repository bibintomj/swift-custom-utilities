//
//  AWSS3Scheduler.swift
//  Reporters App
//
//  Created by sijo on 03/01/20.
//  Copyright © 2020 Hifx. All rights reserved.
//

import AWSS3
import Photos

var now: Date { Date() }
var currentTimeStamp: Int { now.millisecondsSince1970 }

fileprivate extension Date {
    var millisecondsSince1970: Int { Int(timeIntervalSince1970 * 1000.0) }
    
    init(milliseconds: Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}

typealias AWSS3Progress = AWSS3TransferUtilityProgressBlock
typealias AWSS3Task = AWSS3TransferUtilityTask
typealias AWSS3UploadTask = AWSS3TransferUtilityUploadTask
typealias AWSS3Uploaded = AWSS3TransferUtilityUploadCompletionHandlerBlock
typealias AWSS3Downloaded = AWSS3TransferUtilityDownloadCompletionHandlerBlock

enum MediaItem {
    case image, audio, video
    var description: String { String(describing: self) }
    var placeHolder: String { description.capitalizeFirst }
    var previewHolder: String { placeHolder + "-" + "Large" }
    
    var rootFolder: String { "projects" }
    
    func file(path `extension`: String?) -> String {
        
        var `extension`: String {
            switch self {
            case .image: return `extension` ?? "jpeg"
            case .audio: return `extension` ?? "mp3"
            case .video: return `extension` ?? "mov"
            }
        }
        
        return "\(contentName)" + "\(currentTimeStamp)." + `extension`
    }
    
    var contentName: String {
        switch self {
        case .image: return "IMG_"
        case .audio: return "AUD_"
        case .video: return "VID_"
        }
    }
}
    
protocol AWSS3Scheduler {
    var `extension`: String? { get }
    var mimeType: String? { get }
    var placeHolder: String { get }
    var thumbnail: UIImage? { get }
    var fileURL: String? { get }
    var mediaURL: String { get }
    var progress: AWSS3Progress? { get }
    var uploaded: AWSS3Uploaded? { get }
    var downloaded: AWSS3TransferUtilityDownloadCompletionHandlerBlock? { get }
}

extension AWSS3Scheduler {
    var mediaType: MediaItem {
        guard let mimeType = mimeType else { return .image }
        
        if mimeType.contains("video") {
            return .video
        }
        
        if mimeType.contains("image") {
            return .image
        }
        
        return .audio
    }
    var name: String { mediaType.file(path: `extension`) }
    var key: String { mediaType.rootFolder + "/" + name }
    var isUploaded: Bool { !mediaURL.isEmpty }
    var progress: AWSS3Progress? { progress(_:progress:) }
    var uploaded: AWSS3Uploaded? { uploaded(_:error:) }
    var downloaded: AWSS3Downloaded? { downloaded(_:url:data:error:) }
}

extension AWSS3Scheduler {
    
    func upload(with basic: AWSBasicSessionable? = nil) {
        
        let transferUtility: AWSS3TransferUtility? = AWSS3TransferUtility.s3TransferUtility(forKey: basic?.transferKey ?? AWS.S3.transferKey)
        
        let expression = AWSS3TransferUtilityUploadExpression()
        
        if mediaType == .image {
            expression.setValue("public-read", forRequestHeader: "x-amz-acl")
        }
        
        expression.progressBlock = progress
        
        guard let fileURL = fileURL,
              let data = FileManager.default.contents(atPath: fileURL) else {
                uploaded?(.init(), nil)
                return
        }
        
        transferUtility?.uploadData(data,
                            key: basic?.objectKey ?? key,
                            contentType: mimeType ?? "image/jpeg",
                            expression: expression,
                            completionHandler: uploaded).continueWith { (task) -> AnyObject? in
                if let error = task.error {
                    print("Error: \(error.localizedDescription)")
                }

                if task.result != nil {
                    print("Upload Starting!")
                }
                return nil
        }
    }
    
    func download() {
        let transferUtility: AWSS3TransferUtility? = AWSS3TransferUtility.s3TransferUtility(forKey: AWS.S3.transferKey)
        let expression = AWSS3TransferUtilityDownloadExpression()
        expression.progressBlock = progress
        transferUtility?.downloadData(forKey: key,
                                      expression: expression,
                                      completionHandler: downloaded).continueWith { (task) -> AnyObject? in
                if let error = task.error {
                    NSLog("Error: \(error.localizedDescription)")
                }

                if let _ = task.result {
                    NSLog("Download Starting!")
                }
                return nil
            }
    }
    
    private func progress(_ task: AWSS3TransferUtilityTask, progress: Progress) {
        print("\(progress)")
    }
    
    private func uploaded(_ task: AWSS3TransferUtilityUploadTask, error: Error?) {
        if let error = error {
            print("Failed with error: \(error)")
            print("Failed")
        } else {
            print("Success")
            print(task.key)
        }
    }
    
    private func downloaded(_ task: AWSS3TransferUtilityDownloadTask, url: URL?, data: Data?, error: Error?) {
        if let error = error {
            print("Failed with error: \(error)")
            print("Failed")
        } else {
            print("Success")
            print(task.key)
        }
    }
}
