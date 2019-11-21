//
//  SupplementaryComponent.swift
//  HarmonyKit
//
//  Created by Samuel Kirchmeier on 9/16/16.
//  Copyright © 2016 Target. All rights reserved.
//

import Foundation

/**
 *  Wrapper for supplementary views used when registering components via the component provider.
 */
public struct SupplementaryComponent {
    public var component: ComponentType
    public var kind: String

    public init(component: ComponentType, kind: String) {
        self.component = component
        self.kind = kind
    }
}
