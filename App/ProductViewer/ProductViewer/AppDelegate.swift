//
//  AppDelegate.swift
//  ProductViewer
//
//  Created by Erik.Kerber on 8/18/16.
//  Copyright © 2016 Target. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        setInitialViewController()
        return true
    }
    
    private func setInitialViewController() {
        window = UIWindow(frame: UIScreen.main.bounds)
        let initialNavigationController = UINavigationController(rootViewController: ListCoordinator().viewController)
        window?.rootViewController = initialNavigationController
        window?.makeKeyAndVisible()
    }
}

