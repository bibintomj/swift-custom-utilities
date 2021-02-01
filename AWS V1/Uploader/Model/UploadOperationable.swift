//
//  UploadOperationable.swift
//  Quickerala
//
//  Created by Bibin on 23/08/19.
//  Copyright © 2019 Hifx IT & Media Services Private Limited. All rights reserved.
//

import AWSS3

protocol UploadOperationable: class {
    
    /// Implementation of file upload to server.
    ///
    /// - Parameter completion: Callback when upload is completed. true = success; false = failed.
    func startUpload(completion: @escaping (Bool) -> Void)
    
    /// Pauses a currently in progress file upload.
    func pauseUpload()
    
    /// Stops the file upload of a file.
    func abortUpload()
}

extension UploadOperationable where Self: UploadRepresentable & UploadProgressObservable {
    // Default implementation with AWS.
    func startUpload(completion: @escaping ((Bool) -> Void) = { _ in }) {
        /// Returning if file is currently uploading or completed uploading.
        if case .completed = self.status {
            Log.info("File has already been uploaded.")
            completion(false)
            return
        } else if case .uploading = self.status {
            Log.info("File upload already in progress.")
            completion(false)
            return
        }

        Log.info("Starting upload")
    
        let expression = AWSS3TransferUtilityUploadExpression()
        if type == .logo { expression.setValue("logo", forRequestParameter: "x-amz-meta-imgType") }
        if [.image, .logo].contains(type) {
            expression.setValue("true", forRequestParameter: "x-amz-meta-thumb")
        }
        expression.setValue("public-read", forRequestParameter: "x-amz-acl")        
        expression.uploadProgress = { _, _, totalBytesSent, totalBytesExpectedToSend in
            let progressPercentage = Float(totalBytesSent)/Float(totalBytesExpectedToSend)
            self.onProgressChange?(progressPercentage)
            Log.info(progressPercentage)
        }
        
        guard let fileData = localUrl.data else {
            let reason = "Failed to convert file to data."
            Log.error("Upload Failed 👎🏻", reason)
            self.status = .failed(reason: reason)
            self.onFinishUpload?(false)
            completion(false)
            return
        }
        
        let req = AWSS3TransferUtility.s3TransferUtility(forKey: AWSManager.Cognito.serviceClientKey)
        req.uploadData(fileData,
                       bucket: AWSConfig.bucketName,
                       key: awsFolderName + "/" + self.fullName,
                       contentType: mimeType,
                       expression: expression) { (_, error) in
                        guard error == nil else {
                            Log.error("Upload Failed 👎🏻", error ?? "")
                            self.status = .failed(reason: error?.localizedDescription ?? "")
                            self.onFinishUpload?(false)
                            completion(false)
                            return
                        }
                        let aclPutRequest =  AWSS3PutObjectAclRequest()!
                        aclPutRequest.acl = .publicRead
                        aclPutRequest.bucket = AWSConfig.bucketName
                        aclPutRequest.key = self.awsFolderName + "/" + self.fullName
                        
                        let service = AWSS3.default()
                        service.putObjectAcl(aclPutRequest) { (_, putError) in
                            guard putError == nil else {
                                Log.error("Upload Failed 👎🏻", putError ?? "")
                                self.status = .failed(reason: putError?.localizedDescription ?? "")
                                self.onFinishUpload?(false)
                                completion(false)
                                return
                            }
                            Log.info("YAayyyy!!!... Upload Success 💪🏻")
                            self.status = .completed
                            self.onFinishUpload?(true)
                            completion(true)
                        }
        }
        self.status = .uploading
    }
    
    func pauseUpload() {
        // Implentation evaded. Was not in Requirement.
    }
    
    func abortUpload() {
        // Implentation evaded. Was not in Requirement.
        self.status = .cancelled
    }
}

/// Represents the mode of upload when there are multiple files.
///
/// - sequence: Only one upload at a time. Upload completion of one file will start the upload of next file in queue.
/// - parallel: All files will be uploaded simultaneously.
enum UploadMode {
    case sequence, parallel
}

extension Array where Element: Uploadable {
    
    /// A convinence function that calls upload() on the files in the specified manner.
    /// This is a recursive function.
    ///
    /// - Parameter mode: Represents the mode of upload.
    func upload(in mode: UploadMode = .sequence) {
        guard !self.isEmpty else { return }
        
        guard mode == .sequence else {
            forEach { $0.startUpload() }; return
        }
        
        var items = self
        let item = items.removeFirst()
        item.startUpload { _ in items.upload(in: mode) }
    }
}

private extension URL {
    var data: Data? {
        var converted: Data?
        do { converted = try Data(contentsOf: self)
        } catch { Log.error("$$$$ FAILEDD TO CONVETRT", error.localizedDescription) }
        return converted
    }
}
