//
//  TempoCoordinator.swift
//  HarmonyKit
//
//  Created by Kevin.Onken on 2/18/16.
//  Copyright © 2016 Target. All rights reserved.
//

import Foundation

public protocol TempoCoordinator {
    var presenters: [TempoPresenterType] { get set }
    var dispatcher: Dispatcher { get }
}
