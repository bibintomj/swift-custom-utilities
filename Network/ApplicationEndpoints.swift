//
//  EndPoints.swift
//  General
//
//  Created by Bibin on 27/05/19.
//  Copyright © 2019 Hifx IT & Media Services Private Limited. All rights reserved.
//

import Foundation

struct Request {
    /// Configure the requets here, such as setting default headers.
    static func configure() {
        HTTPHeaders.default = HTTPHeaders(headers: [MNetwork.contentType: MNetwork.urlEncoded] + Request.apiRequestDetailHeader.headers)
    }
    
    static var apiRequestDetailHeader: HTTPHeaders {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        return HTTPHeaders(headers: [MNetwork.apiRequestDetails: appVersion + "," + MNetwork.ipAddress + "," + "iPhone"])
    }
    
    static var apiRequestDetailHeaderHit: HTTPHeaders {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        return HTTPHeaders(headers: [MNetwork.apiRequestDetails: appVersion + "," + MNetwork.ipAddress])
    }
    
    static var isLoggedIn: HTTPHeaders {
        let loggedIn: String = Session.token.isEmpty ? .yes : .no//"no"
        return HTTPHeaders(headers: [MNetwork.apiRequestLoggedIn: loggedIn.lowercased()])
    }
}

extension Request {
    
    // MARK: Sample requests
    struct Authorization: Endpoint {
        var path: String {  "/v1/authorize/token" }
        var httpMethod: HTTPMethod { .post }
        var parameters: ParameterConstructable = [:]
    }

    struct Home: Endpoint {
        var environment: Deployment.Environment {
            guard case .production = Deployment.environment else {
                return .custom(url: "https://api.sample.com")
            }
            return .custom(url: "https://api.sample1.com")
        }
        var path: String {  "/mobileAppData/app_home.json" }
        var httpMethod: HTTPMethod { .get }
        var parameters: ParameterConstructable = [:]
    }
    
    struct Search: Endpoint {
        var path: String { "/v1/search?" }
        var httpMethod: HTTPMethod { .get }
        var parameters: ParameterConstructable = [:]
    }
    
    struct UserReviews: Endpoint {
        var path: String { "/v1/business/" + .placeholder + "/reviews?" }
        var urlPathItems: [URLPathItem] = []
        var httpMethod: HTTPMethod { .get }
        var parameters: ParameterConstructable = [:]
    }
    
    struct UpdateBusinessAddress: Endpoint {
        var path: String { "/v1/business/" + .placeholder + "/address/" + .placeholder + "/update?" }
        var httpMethod: HTTPMethod { .put }
        var urlPathItems: [URLPathItem] = []
        var parameters: ParameterConstructable = [:]
        var isSessionRequired: Bool { true }
    }
    
}
