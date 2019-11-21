//
//  TempoViewState.swift
//  HarmonyKit
//
//  Created by Ryan.Sander on 11/4/15.
//  Copyright © 2015 Target. All rights reserved.
//

import Foundation

public protocol TempoViewState {
	
}

public protocol TempoSectionedViewState {
	var sections: [TempoViewStateItem] { get }
	var focus: TempoFocus? { get }
	
	func item(for indexPath: IndexPath) -> TempoViewStateItem
	func supplementaryItem(for indexPath: IndexPath) -> TempoViewStateItem
}

public extension TempoSectionedViewState {
	var focus: TempoFocus? {
		return nil
	}
	
	func item(for indexPath: IndexPath) -> TempoViewStateItem {
		let section = sections[indexPath.section]
		
		if let items = section.items {
			return items[indexPath.item]
		} else {
			return section
		}
	}
	
	func supplementaryItem(for indexPath: IndexPath) -> TempoViewStateItem {
		guard let section = sections[indexPath.section] as? TempoViewStateSection, let header = section.header else {
			fatalError("No view state for supplementary view at index path \(indexPath)")
		}
		
		return header
	}
}

// MARK: - MemoizedTempoSectionedViewState

/**
*  Copies view state for internal use to avoid expense when sections are calculated.
*/
struct MemoizedTempoSectionedViewState: TempoViewState, TempoSectionedViewState {
	let sections: [TempoViewStateItem]
	let focus: TempoFocus?
	
	init(viewState: TempoSectionedViewState) {
		self.sections = viewState.sections
		self.focus = viewState.focus
	}
}
