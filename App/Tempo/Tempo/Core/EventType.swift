//
//  EventType.swift
//  HarmonyKit
//
//  Created by Ryan.Sander on 1/19/16.
//  Copyright © 2016 Target. All rights reserved.
//

import Foundation

public protocol EventType {
    static var key: String { get }
}

public extension EventType {
    static var key: String {
        return String(describing: type(of: self))
    }
}
