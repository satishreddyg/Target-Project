//
//  TempoViewStateSection.swift
//  HarmonyKit
//
//  Created by Samuel Kirchmeier on 9/14/16.
//  Copyright © 2016 Target. All rights reserved.
//

import Foundation

public protocol TempoViewStateSection: TempoViewStateItem {
    var header: TempoViewStateItem? { get }
}
