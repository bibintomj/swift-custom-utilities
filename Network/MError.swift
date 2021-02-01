//
//  MError.swift
//  Quickerala
//
//  Created by Bibin on 13/06/19.
//  Copyright © 2019 Hifx IT & Media Services Private Limited. All rights reserved.
//

import Foundation

typealias MError = MResponse.MError

/// This class stuctured this way to adapt to error responses structure from server and to improve Readability.
struct MResponse: Codable {
    typealias StatusCode = Int
    struct MError: Error {
        typealias Message = String
        
        var code: Int
        var type: String
        var message: String
        var responseStatusCode: Int = -1
    }
    
    var error: MError
}

extension MError: Codable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        code = (try? values.decodeIfPresent(Int.self, forKey: .code)) ?? Int((try? values.decodeIfPresent(String.self, forKey: .code)) ?? "0") ?? 0
        type = try values.decode(String.self, forKey: .type)
        message = try values.decode(String.self, forKey: .message)
    }
}

/// MError equatable conformance
extension MError: Equatable {
    public static func == (lhs: MError, rhs: MError) -> Bool {
        return lhs.code == rhs.code &&
               lhs.type == rhs.type &&
               lhs.message == rhs.message
    }
}

/// Known errors
extension MError {
    static let unknown = MError(code: .unknown, type: .unknown, message: .unknown)
    
    static let timeout = MError(code: .timeout, type: .timeout, message: MError.Message.timeout)
    
    static let connectionFailure = MError(code: .connectionFailure, type: .connectionFailure, message: .connectionFailure)
    
    static let noNetwork = MError(code: .noNetwork, type: .noNetwork, message: .noNetwork)
    
    static let dataProcessingFailed = MError(code: .dataProcessingFailed, type: .dataProcessingFailed, message: .dataProcessingFailed)
    
    static let invalidResponse = MError(code: .invalidResponse, type: .invalidResponse, message: .invalidResponse)
    
    static let unauthorized = MError(code: .unauthorized, type: .unauthorized, message: .unauthorized)
}

/// Known Status Codes
extension MResponse.StatusCode {    
    static let unknown                = 0
    static let success                = 200
    static let invalidResponse        = 204
    static let invalidRequest         = 400
    static let unauthorized           = 401
    static let invalid                = 404
    static let notImplemented         = 501
    
    // Internal status codes. These are not defined in server.
    static let timeout                = 990
    static let connectionFailure      = 991
    static let noNetwork              = 992
    static let dataProcessingFailed   = 993
}

extension MError.Message {
    static let unknown              = "Something went wrong.\n Please contact our support team for furthur ."
    static let timeout              = "Connection timed out."
    static let connectionFailure    = "Failed to contact the server."
    static let noNetwork            = "Internet connection appears to be offline."
    static let dataProcessingFailed = "Failed to read the response."
    static let invalidResponse      = "Invalid Response"
    static let unauthorized         = "Authorization failed"
    static let message              = "General Message"
}

struct GeneralResponse: Codable {
    let message: String
    let id: Int?
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        message = try values.decodeIfPresent(String.self, forKey: .message) ?? ""
        id = try values.decodeIfPresent(Int.self, forKey: .id) ?? 0
    }
}
