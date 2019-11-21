//
//  NetworkManager.swift
//  ProductViewer
//
//  Created by Satish Garlapati on 11/17/19.
//  Copyright © 2019 Target. All rights reserved.
//

import Foundation

/**
 Manager class for managing all the web service request's
 - constructing path's, additional headers, constructing parameters would happen here before performing request's
 */

class NetworkManager: NetworkClient {
    
    // singleton
    static let shared = NetworkManager()
    private override init() {}

    func fetchDeals(_ completion: @escaping (_ dealsResponse: TargetResponse?, _ error: CustomError?) -> ()) {
        performRequest(.get, path: "/api/deals") { [weak self] responseObject in
            self?.responseDataHandler(response: responseObject, completionHandler: { (response, error) in
                completion(response, error)
            })
        }
    }
}

extension NetworkManager {
    //MARK: Generic methods
    func responseDataHandler<T: Codable>(response: ResponseObject, completionHandler: @escaping (_ result: T?, _ error: CustomError?) -> ()) {
        guard response.error == nil else {
            completionHandler(nil, response.error as? CustomError)
            return
        }
        do {
            guard let _data = response.data else {
                completionHandler(nil, CustomError.invalidData)
                return
            }
            let result = try JSONDecoder().decode(T.self, from: _data)
            completionHandler(result, nil)
        } catch let error {
            completionHandler(nil, error as? CustomError)
        }
    }
}
