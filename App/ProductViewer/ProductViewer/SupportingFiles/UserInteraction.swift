//
//  ListEvents.swift
//  ProductViewer
//
//  Created by Erik.Kerber on 8/19/16.
//  Copyright © 2016 Target. All rights reserved.
//

import Tempo

/// user interactin types
enum ActionType {
    case addToCart, addToList, selectedListItem(_ item: TempoViewStateItem)
}

/**
 single EventType struct to differentiate between multiple user interactions instead of using multiple eventType's
 - used for dispatcher observer & trigger events
 */
struct UserInteraction: EventType {
    let type: ActionType
}
