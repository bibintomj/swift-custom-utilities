//
//  Request.swift
//  ManoramaKit
//
//  Created by sijo on 10/04/19.
//  Copyright © 2019 Hifx. All rights reserved.
//

import Foundation

// MARK: Type Alias Declaration for Request
//----------------------------------------------------------------------------------------------
typealias HTTPBody    = Data

typealias URLPathItem = String

// MARK: HTTPMethod Declaration
//----------------------------------------------------------------------------------------------
/// Specify the http methods.
enum HTTPMethod: String {
    case get    = "GET"
    case post   = "POST"
    case put    = "PUT"
    case delete = "DELETE"
}

struct HTTPHeaders {
    /// Holds headers for all requests
    private(set) var headers: [String: String]
    /// Holds default headers that is sent in all requests. Must be set from outside.
    static var `default`: HTTPHeaders = HTTPHeaders(headers: [:])
}

extension HTTPHeaders {
    static func + (lhs: HTTPHeaders, rhs: HTTPHeaders) -> HTTPHeaders {
        var combined = lhs.headers
        rhs.headers.forEach { combined[$0.key] = $0.value }
        return HTTPHeaders(headers: combined)
    }
}

// MARK: Endpoint Protocol Declarartion
//----------------------------------------------------------------------------------------------
/// This will be the a Request Endpoint.
protocol Endpoint {
    var url: URL? { get }
    /// Return the enviorment, ex: Production, Stage, Beta.
    var environment: Deployment.Environment { get }
    /// Returns request path, commonly we call API path.
    var path: String { get }
    /// Components to replace in URL placeholder
    var urlPathItems: [URLPathItem] { get }
    /// Returns the request method, We use POST for most of the API's.
    var httpMethod: HTTPMethod { get }
    /// Returns the request parameters.
    var parameters: ParameterConstructable { get }
    /// Returns the request headers.
    var httpHeaders: HTTPHeaders? { get }
    /// Returns the request timeout.
    var timeout: TimeInterval { get }
    /// returns if session should be considered.
    var isSessionRequired: Bool { get }
    
    var encodeModal: Encodable { get }
}

/// Default customization for the requirements of EndPoint Protocol.
extension Endpoint {
    var environment: Deployment.Environment { return Deployment.environment }
    var httpHeaders: HTTPHeaders? { return HTTPHeaders.default }
    var urlPathItems: [URLPathItem] { return [] }
    var timeout: TimeInterval { return 30 }
    var isSessionRequired: Bool { return false }
}

extension Endpoint {
    
    /// Returns request URL.
    public var url: URL? {
        
        var urlString = environment.url + path.with(urlPathItems)
        // Append query string if GET.00
        
        if httpMethod == .get {
            urlString += parameters.query
            urlString  = isSessionRequired ? urlString.withSession : urlString
        }
        
        /// We are adding time stamp to the end of URL. This is to avoid cached data getting returned.
        let appendCharacter = urlString.contains("?") ? "&" : "?"
        urlString += appendCharacter + Date.currentTimeInMilliSecondsQuery
//        return URL(string: urlString.percentEncoding)
        return URL(string: urlString)
    }
    
    /// Returns URL Request.
    var request: URLRequest {
        /// Initaize a URL Request.
        var request = URLRequest(url: url!)
        // Set http method.
        request.httpMethod = httpMethod.rawValue
        // Set body if POST.
        var headers = httpHeaders?.headers ?? [:]
        switch httpMethod {
        case .post:
            var query = parameters.query
            query = isSessionRequired ? query.withSession : query
            request.httpBody = query.data(using: .utf8)
        case .put, .delete:
            headers += isSessionRequired ? Session.token.authorizationBearer : [:]
            request.httpBody = parameters.query.data(using: .utf8)
        default:
            break
        }
        request.allHTTPHeaderFields = headers
        /// Set request timeout.
        request.timeoutInterval = timeout
        // Returns the request.
        return request
    }
}

// MARK: String Helper for Encoding
//----------------------------------------------------------------------------------------------
private extension String {
    /// Returns the character set for characters allowed in a query URL component.
    var percentEncoding: String { return addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "" }
}

extension URLPathItem {
    static var placeholder: String { return " \(#function)>" }
    
    func with(_ pathItems: [URLPathItem]) -> String {
        /// Replacement is done from end to the begining of the string so that ranges doesnt vary after each replacement.
        var params = pathItems
        params.reverse()
        var path = self
        let ranges = path.ranges(of: URLPathItem.placeholder)
        
        ranges.reversed().enumerated().forEach {
            let aParam = params.removeFirst()
            path.replaceSubrange($0.element, with: aParam)
        }
        return path //+ params.query
    }
}

// MARK: Transforms Enum RawValue to StringValue
//----------------------------------------------------------------------------------------------
//private extension Deployment.Environment {
//    var stringValue: String {
//        switch self {
//        case .production(let url): return url
//        case .staging(let url): return url
//        case .custom(let url): return url
//        }
//    }
//}

/// This was created since some APIs support query strings (eg: ?key1=value1&key2=value2) and some support paths (eg: /business/456)
/// Types conforming to this type must be able to generate query.
protocol ParameterConstructable {
    var query: String { get }
}

extension Array: ParameterConstructable where Element == String {
    var query: String { return self.joined(separator: "/") }
}

extension Dictionary: ParameterConstructable where Key == String, Value == String {
    var query: String {
        return map { "\($0.key)".percentEncoding + "=" + "\($0.value)" .percentEncoding }.joined(separator: "&")
    }
}

private extension String {
    var withSession: String {
        let sessionString = Session.token.dictionary.query.percentEncoding
        return self.last == "?" ? self + sessionString : self + "&" + sessionString
    }
    
    func indices(of text: String) -> [Int] {
        var indices = [Int]()
        var position = startIndex
        while let range = range(of: text, range: position..<endIndex) {
            let calculatedIndex = distance(from: startIndex,
                             to: range.lowerBound)
            indices.append(calculatedIndex)
            let offset = text.distance(from: text.startIndex,
                                             to: text.endIndex) - 1
            guard let after = index(range.lowerBound,
                                    offsetBy: offset,
                                    limitedBy: endIndex) else {
                                        break
            }
            position = index(after: after)
        }
        return indices
    }
    
    func ranges(of text: String) -> [Range<String.Index>] {
        let allIndices = indices(of: text)
        let count = text.count
        return allIndices.map({ index(startIndex, offsetBy: $0)..<index(startIndex, offsetBy: $0+count) })
    }
}

private extension Date {
    static var currentTimeInMilliSeconds: Int64 { Int64(Date().timeIntervalSince1970 * 1000) }
    static var currentTimeInMilliSecondsQuery: String { "time=\(currentTimeInMilliSeconds)" }
}
