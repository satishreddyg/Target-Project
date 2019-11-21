//
//  NetworkClient.swift
//  ProductViewer
//
//  Created by Satish Garlapati on 11/17/19.
//  Copyright © 2019 Target. All rights reserved.
//

import Foundation

public typealias Parameters = [String: Any]
public typealias HTTPHeaders = [String: String]

enum RequestMethod: String {
    case get, post, delete, put
}

// Swift Result type
// Available by default from Xcode 10.2 but this project doesn't have support for 10.2 so custom implementation of same Result type
enum Result<Success, Failure> {
    case success(Success)
    case failure(Failure)
}

enum CustomError: Error {
    /// request/response failure
    case invalidURL(url: String), invalidData, jsonEncodingFailed(error: Error)
    
    /// custom message pass through
    case message(errorMessage: String)
}

/*
 This would be a global class for networking without help of any third party networking dependencies. We can extend the functionality based on needs but this would suffice as a base platform to further build on
 */

class NetworkClient: NSObject {
    
    // if we need to change this from a different place (example if we have multiple QA environments), remove private keyword
    private let BASE_URL = "http://target-deals.herokuapp.com"
    /// typealias
    public typealias ResponseHandler = (ResponseObject) -> Void
    public typealias ResponseObject = (httpUrlResponse: HTTPURLResponse?, data: Data?, error: Error?)
    
    /**
     Global method to perform all request types and chains the response depending on type
     */
    func performRequest(_ requestMethod: RequestMethod,
                        path: String,
                        base:String? = nil,
                        parameters: Parameters? = nil,
                        headers: [String:String] = [:],
                        responseHandler: @escaping ResponseHandler) {
        //-- BUILD REQUEST
        let request = buildRequest(getUrlString(withPath: path, and: base), requestMethod: requestMethod, parameters: parameters, headers: headers)
        switch request {
        case .success(let urlRequest):
            URLSession.shared.dataTask(with: urlRequest) { (data, urlResponse, error) in
                responseHandler((urlResponse as? HTTPURLResponse, data, error))
                }.resume()
        case .failure(let error):
            responseHandler((nil, nil, error))
        }
    }
    
    /**
     builds URLRequest with encoding parameters, if required
     - argument requestMethod: required httpMethod
     - argument OPTIONAL parameters: parameters needed for POST/PUT call
     - argument headers: passed on extra httpHeaders
     - returns: Result type of URLRequest and Error.
     */
    @discardableResult
    open func buildRequest(_ urlString: URLConvertible,
                           requestMethod: RequestMethod,
                           parameters: Parameters? = nil,
                           headers: HTTPHeaders = [:]) -> Result<URLRequest, Error> {
        do {
            var request = try URLRequest(url: urlString.asURL(), cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0)
            request.httpMethod = requestMethod.rawValue.uppercased()
            request.httpShouldHandleCookies = false
            request.allHTTPHeaderFields = getHeaders(headers)
            request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
            let encodedURLRequest = try request.encodeUrlRequest(with: parameters)
            return .success(encodedURLRequest)
        } catch let error {
            return .failure(error)
        }
    }
    
    /**
     returns the constructed path
     Arguments:
     - path to append: if the path starts with http, then its a external path so return directly
     If not, append the baseUrl to the path
     */
    private func getUrlString(withPath path: String, and _baseUrl: String?) -> String {
        guard !path.hasPrefix("http") else { return path }
        guard let baseUrl = _baseUrl else {
            return BASE_URL + path
        }
        return baseUrl + path
    }
    
    /**
     Constructs headers, if passed any. If not, return common headers
     */
    private func getHeaders(_ headers:[String:String]) -> HTTPHeaders {
        var authenticationHeaders = [String: String]()
        /**
         if multiple apps exist, appKey can be passed to differentiate
         var authenticationHeaders = ["appKey": "can be app specific key"]
         if token is needed
         //authenticationHeaders["tokenKey"] = token
        */
        for header in headers {
            authenticationHeaders[header.key] = header.value
        }
        return authenticationHeaders
    }
}

public protocol URLConvertible {
    /**
     Returns a URL that conforms to RFC 2396 or throws an `Error`.
     - throws: An `Error` if the type cannot be converted to a `URL`.
     - returns: A URL or throws an `Error`.
     */
    func asURL() throws -> URL
}

extension String: URLConvertible {
    public func asURL() throws -> URL {
        guard let url = URL(string: self) else { throw CustomError.invalidURL(url: self) }
        return url
    }
}

public protocol ParameterEncoding {
    /**
     Creates a URL request by encoding parameters and applying them onto an existing request.
     - parameter urlRequest: The request to have parameters applied.
     - parameter parameters: The parameters to apply.
     - throws: An `CustomError.parameterEncodingFailed` error if encoding fails.
     - returns: The encoded request.
     */
    mutating func encodeUrlRequest(with parameters: Parameters?) throws -> URLRequest
}

extension URLRequest: ParameterEncoding {
    public mutating func encodeUrlRequest(with parameters: Parameters?) throws -> URLRequest {
        guard let parameters = parameters else { return self }
        do {
            let data = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            if value(forHTTPHeaderField: "Content-Type") == nil {
                setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
            httpBody = data
        } catch {
            throw CustomError.jsonEncodingFailed(error: error)
        }
        return self
    }
}
