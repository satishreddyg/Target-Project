//
//  HarmonyScreen.swift
//  HarmonyKit
//
//  Created by Erik Kerber on 11/10/15.
//  Copyright © 2015 Target. All rights reserved.
//

import UIKit

public struct HarmonyScreen {
    public static let onePixel = 1 / UIScreen.main.scale
}

@objc
open class HarmonyScreenObjC: NSObject {
    open static let onePixel = 1 / UIScreen.main.scale
}
