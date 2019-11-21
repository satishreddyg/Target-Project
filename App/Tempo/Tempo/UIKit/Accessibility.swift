//
//  Accessibility.swift
//  HarmonyKit
//
//  Created by Adam May on 3/16/16.
//  Copyright © 2016 Target. All rights reserved.
//

import UIKit

@objc open class Accessibility : NSObject {
    open static func announce(_ announcement: String) {
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, announcement)
    }

    open static func announce(_ announcement: String, afterDelay delay: TimeInterval) {
        after(delay) {
            announce(announcement)
        }
    }
    
    /**
     *  If you add/remove elements from the screen and don't want to give them focus, posting a layout changed notification will make them discoverable/undiscoverable for accessibility.
     *
     *  - Parameter announcement: An optional announcement to coincide with the layout change.
     */
    open static func postLayoutChanged(_ announcement: String? = nil) {
        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, announcement);
    }

    open static func announceScreenChanged(andFocusView view: UIView) {
        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, view)
    }

    open static func announceScreenChanged(andSpeakAnnouncement announcement: String) {
        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, announcement)
    }
    
    open static func announceScreenChanged(andSpeakAnnouncement announcement: String, afterDelay delay: TimeInterval) {
        after(delay) {
            UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, announcement)
        }
    }
}

public extension UIView {
    func focusAccessibility() {
        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, self);
    }

    func focusAccessibility(afterDelay delay: TimeInterval) {
        after(delay) {
            self.focusAccessibility()
        }
    }
}
