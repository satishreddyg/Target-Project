//
//  TempoViewStateItem.swift
//  HarmonyKit
//
//  Created by Adam May on 11/9/15.
//  Copyright © 2015 Target. All rights reserved.
//

import Foundation

public protocol TempoViewStateItem {
    var identifier: String { get }
    var numberOfItems: Int { get }
    var focused: Bool { get }
    var items: [TempoViewStateItem]? { get }

    func isEqualTo(_ other: TempoViewStateItem) -> Bool
}

public extension TempoViewStateItem {
    var identifier: String {
        return String(describing: type(of: self))
    }

    var numberOfItems: Int {
        if let items = items {
            return items.count
        } else {
            return 1
        }
    }

    var focused: Bool {
        return false
    }

    var items: [TempoViewStateItem]? {
        return nil
    }

    func isEqualTo(_ other: TempoViewStateItem) -> Bool {
        return numberOfItems == other.numberOfItems
    }
}

public extension TempoViewStateItem where Self : Equatable {
    func isEqualTo(_ other: TempoViewStateItem) -> Bool {
        guard let o = other as? Self else {
            return false
        }

        return self == o
    }
}

public func == (lhs: [TempoViewStateItem], rhs: [TempoViewStateItem]) -> Bool {
    return lhs.count == rhs.count
        && !zip(lhs, rhs).contains(where: { !$0.0.isEqualTo($0.1) })
}

public func == (lhs: [TempoViewStateItem]?, rhs: [TempoViewStateItem]?) -> Bool {
    switch (lhs, rhs) {
    case (.some(let left), .some(let right)):
        return left == right
    case (.none, .none):
        return true
    default:
        return false
    }
}

