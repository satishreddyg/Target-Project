//
//  SectionPresenter.swift
//  HarmonyKit
//
//  Created by Adam May on 11/9/15.
//  Copyright © 2015 Target. All rights reserved.
//

import Foundation

public enum CollectionViewSectionUpdate: Equatable {
	case insert(Int)
	case delete(Int)
	case reload(Int)
	case update(Int, Int, [CollectionViewItemUpdate])
	case focus(TempoFocus)
	case header(Int, Int)
}

public func == (lhs: CollectionViewSectionUpdate, rhs: CollectionViewSectionUpdate) -> Bool {
	switch (lhs, rhs) {
	case (.insert(let leftIndex), .insert(let rightIndex)):
		return leftIndex == rightIndex
	case (.delete(let leftIndex), .delete(let rightIndex)):
		return leftIndex == rightIndex
	case (.reload(let leftIndex), .reload(let rightIndex)):
		return leftIndex == rightIndex
	case (.update(let leftFromIndex, let leftToIndex, let leftItemUpdates), .update(let rightFromIndex, let rightToIndex, let rightItemUpdates)):
		return leftFromIndex == rightFromIndex && leftToIndex == rightToIndex && leftItemUpdates == rightItemUpdates
	case (.focus(let leftFocus), .focus(let rightFocus)):
		return leftFocus == rightFocus
	case (.header(let leftUpdate), .header(let rightUpdate)):
		return leftUpdate == rightUpdate
	default:
		return false
	}
}

public enum CollectionViewItemUpdate: Equatable {
	case insert(Int)
	case delete(Int)
	case update(Int, Int)
}

public func == (lhs: CollectionViewItemUpdate, rhs: CollectionViewItemUpdate) -> Bool {
	switch (lhs, rhs) {
	case (.insert(let leftIndex), .insert(let rightIndex)):
		return leftIndex == rightIndex
	case (.delete(let leftIndex), .delete(let rightIndex)):
		return leftIndex == rightIndex
	case (.update(let leftFromIndex, let leftToIndex), .update(let rightFromIndex, let rightToIndex)):
		return leftFromIndex == rightFromIndex && leftToIndex == rightToIndex
	default:
		return false
	}
}

public protocol SectionPresenterAdapter: class {
	func applyUpdates(_ updates: [CollectionViewSectionUpdate], viewState: TempoSectionedViewState)
}

public final class SectionPresenter: NSObject, TempoPresenter {
	public var dispatcher: Dispatcher?
	fileprivate var viewState: MemoizedTempoSectionedViewState?
	fileprivate let adapter: SectionPresenterAdapter
	fileprivate static let serialQueue = DispatchQueue(label: "com.target.tempo.sectionPresenter")
	
	public init(adapter: SectionPresenterAdapter) {
		self.adapter = adapter
	}
	
	public func present(_ viewState: TempoSectionedViewState) {
		let memoizedViewState = MemoizedTempoSectionedViewState(viewState: viewState)
		
		guard let fromViewState = self.viewState else {
			self.viewState = memoizedViewState
			adapter.applyUpdates([], viewState: memoizedViewState)
			return
		}
		
		self.viewState = memoizedViewState
		
		SectionPresenter.serialQueue.async {
			let updates = SectionPresenter.updatesFrom(fromViewState, toViewState: memoizedViewState)
			
			DispatchQueue.main.async { [weak self] in
				self?.adapter.applyUpdates(updates, viewState: memoizedViewState)
			}
		}
	}
	
	fileprivate static func updatesFrom(_ fromViewState: TempoSectionedViewState, toViewState: TempoSectionedViewState) -> [CollectionViewSectionUpdate] {
		var updates = [CollectionViewSectionUpdate]()
		
		let previousSections = fromViewState.sections
		let updatedSections = toViewState.sections
		
		for (index, updated) in updatedSections.enumerated() {
			if !previousSections.contains(where: { $0.identifier == updated.identifier }) {
				updates.append(.insert(index))
			}
		}
		
		for (index, previous) in previousSections.enumerated() {
			if !updatedSections.contains(where: { $0.identifier == previous.identifier }) {
				updates.append(.delete(index))
			}
		}
		
		for (fromIndex, previous) in previousSections.enumerated() {
			if let (toIndex, updated) = updatedSections.enumerated().first(where: { $0.element.identifier == previous.identifier && !$0.element.isEqualTo(previous) }) {
				if let previousItems = previous.items, let updatedItems = updated.items {
					let itemUpdates = updatesFrom(previousItems, toItems: updatedItems)
					updates.append(.update(fromIndex, toIndex, itemUpdates))
				} else if previous.numberOfItems == updated.numberOfItems {
					updates.append(.update(fromIndex, toIndex, []))
				} else {
					updates.append(.reload(fromIndex))
				}
			}
		}
		
		if let focus = toViewState.focus {
			updates.append(.focus(focus))
		}
		
		for (fromIndex, previous) in previousSections.enumerated() {
			if let (toIndex, updated) = updatedSections.enumerated().first(where: { $0.element.identifier == previous.identifier }) {
				if let previous = previous as? TempoViewStateSection, let updated = updated as? TempoViewStateSection {
					guard let previousHeader = previous.header, let updatedHeader = updated.header else {
						continue
					}
					
					if !previousHeader.isEqualTo(updatedHeader) {
						updates.append(.header(fromIndex, toIndex))
					}
				}
			}
		}
		
		return updates
	}
	
	fileprivate static func updatesFrom(_ fromItems: [TempoViewStateItem], toItems: [TempoViewStateItem]) -> [CollectionViewItemUpdate] {
		var updates: [CollectionViewItemUpdate] = []
		
		for (index, updated) in toItems.enumerated() {
			if !fromItems.contains(where: { $0.identifier == updated.identifier }) {
				updates.append(.insert(index))
			}
		}
		
		for (index, previous) in fromItems.enumerated() {
			if !toItems.contains(where: { $0.identifier == previous.identifier }) {
				updates.append(.delete(index))
			}
		}
		
		for (fromIndex, previous) in fromItems.enumerated() {
			if let (toIndex, _) = toItems.enumerated().first(where: { $0.element.identifier == previous.identifier && !$0.element.isEqualTo(previous) }) {
				updates.append(.update(fromIndex, toIndex))
			}
		}
		
		return updates
	}
}
