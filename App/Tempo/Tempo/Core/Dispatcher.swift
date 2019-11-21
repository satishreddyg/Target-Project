//
//  Dispatcher.swift
//  HarmonyKit
//
//  Created by Adam May on 11/10/15.
//  Copyright © 2015 Target. All rights reserved.
//

import Foundation

public final class Dispatcher {
    fileprivate var observers = [String: NSHashTable<AnyObject>]()

    // MARK: Init

    public init() {}

    // MARK: Subscribe

    public func addObserver<T: EventType>(_ eventType: T.Type, onEvent: @escaping (T) -> ()) {
        let observer = Observer<T>(notify: onEvent)

        if let eventSpecificObservers = observers[eventType.key] {
            eventSpecificObservers.add(observer)
            return
        }
        observers[eventType.key] = NSHashTable()
        observers[eventType.key]?.add(observer)
    }

    // MARK: Notification

	public func triggerEvent<T: EventType>(_ event: T) {
		guard let observers = observers[type(of: event).key] else { return }
		
		for observer in observers.allObjects {
			guard let observer = observer as? Observer<T> else { continue }
			observer.notify(event)
		}
	}
}

// MARK: Observer Protocols

private final class Observer<T> {
    init(notify: @escaping (T) -> ()) {
        self.notify = notify
    }
    var notify: (T) -> ()
}

/**
 *  Private extension created to eliminate casting throughout this class.
 */
//private extension NSHashTable {
//    func forEachObserver<T>(_ action: (T) -> ()) {
//        self.allObjects.forEach { observer in
//            if let castedObserver = observer as? T {
//                action(castedObserver)
//            }
//        }
//    }
//}
