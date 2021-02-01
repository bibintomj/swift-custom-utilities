//
//  APIMapper+Extension.swift
//  MMNews
//
//  Created by sijo on 07/05/19.
//  Copyright © 2019 Hifx. All rights reserved.
//

import UIKit

enum Result<T: Decodable, U: Error> {
    case success(T)
    case failure(U)
}

/// Placeholder for generic type completion.
typealias GenericResult<T: Decodable> = (Result<T, MResponse.MError>) -> Void

final class MNetwork {
    
    /// Specify the request time out.
    private static var requestTimeout: TimeInterval = 30.0
    
    private static let commonDispatch = DispatchQueue.global(qos: .background)
    
    private static let semaphore = DispatchSemaphore(value: 1)
    
    // MARK: Public Methods
    //----------------------------------------------------------------------------------------------
    /// A generic request response method.
    /// - Parameter requestType: Specify the type of the request.
    /// - Parameter completion: Completed with generic model, which must be conformed to Codable, at least Decodable protocol.
    static func initiateRemoteRequest<T: Decodable, U: Endpoint>(with request: U, with completion: @escaping GenericResult<T> = {_  in }) {
        #if DEBUG
        Swift.print("\t⚾️ \(request.httpMethod.rawValue)ING =>\t\(String(describing: request.url!))",
                    "\n\t\tPARAMS =>\t\(request.parameters)",
            "\n\t\tHEADER =>\t\(String(describing: request.request.allHTTPHeaderFields ?? [:]))")
        #endif
 
        // Semaphore is used here so as to prevent multiple session refresh during concurrent requests.
        if request.isSessionRequired {
            commonDispatch.async {
                semaphore.wait()
                Session.getToken { sessionToken in
                    guard sessionToken != nil else {
                        completion(.failure(.unauthorized))
                        commonDispatch.async { semaphore.signal() }
                        return
                    }
                    start(request, with: completion)
                    commonDispatch.async { semaphore.signal() }
                }
            }
            return
        }
        start(request, with: completion)
    }
    
}

private extension MNetwork {
    static func start<T: Decodable, U: Endpoint>(_ request: U, with completion: @escaping GenericResult<T> = {_  in }) {

        /// Verify the request.
        guard request.url != nil else {
            let error = MResponse.MError(code: MResponse.StatusCode.invalidRequest, type: "Empty URL", message: "No URL specified")
            completion(.failure(error))
            return
        }
        
        // Shows network indicator on the device status bar once request starts.
        DispatchQueue.main.async { UIApplication.shared.isNetworkActivityIndicatorVisible = true }
        
        /// Initialize data task.
        let task = URLSession.shared.dataTask(with: request.request) { (data, response, error) in
            // Hides network indicator on the device status bar once request is completed.
            DispatchQueue.main.async { UIApplication.shared.isNetworkActivityIndicatorVisible = false }
            #if DEBUG
            // swiftlint:disable:next line_length
            Swift.print("\t🥎 RESPONSE(\(String(describing: request.path.with(request.urlPathItems)))) \((response as? HTTPURLResponse)?.statusCode ?? -1) =>",
                "\n\(String(describing: data?.dictionary))")
            #endif
            
            let responseStatusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            
            guard error == nil else {
                // Failed Due to some internal error; such as Network or timeout etc
                var mError = error!.mError
                mError.responseStatusCode = responseStatusCode
                completion(.failure(mError))
                return
            }
            
            guard response?.isHTTPURLResponse ?? false, let data = data else {
                // Not a valid Response
                var mError = MError.invalidResponse
                mError.responseStatusCode = responseStatusCode
                completion(.failure(.invalidResponse))
                return
            }
            
            func successBlock() -> Bool {
                if let decodedModel: T = data.decode() {
                    completion(.success(decodedModel) )
                    return true
                }
                return false
            }
            
            func failureBlock() {
                if let decodedResponse: MResponse = data.decode() {
                    // else try decoding it to Error response
                    var decodedError = decodedResponse.error
                    decodedError.code == .unauthorized ? Session.refresh() : ()
                    decodedError.responseStatusCode = responseStatusCode
                    completion(.failure(decodedError))
                } else if let generalMessage: GeneralResponse = data.decode() {
                    var error = MError(code: .unknown, type: MError.Message.message, message: generalMessage.message)
                    error.responseStatusCode = responseStatusCode
                    completion(.failure(error))
                } else {
                    // Else complete with a default error case.
                    var mError = MError.dataProcessingFailed
                    mError.responseStatusCode = responseStatusCode
                    completion(.failure(mError))
                }
            }
            
//            let genralSuccessStatusCodes: [Int] = [Int](200...299)
//            if genralSuccessStatusCodes.contains(responseStatusCode) {
                if responseStatusCode != 200 {
                    failureBlock()
                    return
                }
//            }
            
            if !successBlock() { failureBlock() }

        }
        task.resume()
    }
    
}

private extension Data {
    
    /// Converts JSON Data to dictionary
    var dictionary: [String: Any]? {
        return try? JSONSerialization.jsonObject(with: self, options: .mutableContainers) as? [String: Any]
    }
    
    var description: String { return String(decoding: self, as: UTF8.self) }
    
    /// Decodes Data to the inferred type.
    func decode<T: Decodable>() -> T? {
        do { return try JSONDecoder().decode(T.self, from: self)
        } catch { Log.severe("FAILED TO GENERATE MODEL \(T.self)", error) }
        return nil
    }
    
}

private extension Error {
    var mError: MResponse.MError {
        switch (self as NSError).code {
        case NSURLErrorTimedOut: return .timeout
        case NSURLErrorCannotConnectToHost, NSURLErrorCannotFindHost: return .connectionFailure
        case NSURLErrorNotConnectedToInternet, NSURLErrorNetworkConnectionLost: return .noNetwork
        default: return .unknown
        }
    }
}

private extension URLResponse {
    var isHTTPURLResponse: Bool { return (self as? HTTPURLResponse) != nil }
}
