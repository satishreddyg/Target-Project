//
//  TargetITem.swift
//  ProductViewer
//
//  Created by Satish Garlapati on 11/17/19.
//  Copyright © 2019 Target. All rights reserved.
//

import Foundation
import Tempo

// using single object for listViewItem and detail view
struct TargetItem: Codable, TempoViewStateItem {
    let title, price, imageUrl, itemDescription, guid: String
    
    enum CodingKeys: String, CodingKey {
        case imageUrl = "image"
        case itemDescription = "description"
        case title, price, guid
    }
}

extension TargetItem: Equatable {
    /*
     checking for unique identifier equality is good enough to confirm if two items are equal
     ASSUMING unique identifiers never be same
    */
    static func ==(lhs: TargetItem, rhs: TargetItem) -> Bool {
        return lhs.guid == rhs.guid
    }
}


