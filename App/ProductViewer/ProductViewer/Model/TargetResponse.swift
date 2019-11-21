//
//  DealResponse.swift
//  ProductViewer
//
//  Created by Satish Garlapati on 11/17/19.
//  Copyright © 2019 Target. All rights reserved.
//

import Foundation

// just consume what we need from the actual response
struct TargetResponse: Codable {
    let deals: [TargetItem]
    
    enum CodingKeys: String, CodingKey {
        case deals = "data"
    }
}
