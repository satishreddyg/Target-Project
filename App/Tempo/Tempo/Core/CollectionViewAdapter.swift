//
//  CollectionViewAdapter.swift
//  HarmonyKit
//
//  Created by Adam May on 11/13/15.
//  Copyright © 2015 Target. All rights reserved.
//

import UIKit

open class CollectionViewAdapter: NSObject {
	public weak var scrollViewDelegate: UIScrollViewDelegate?
	
	fileprivate let collectionView: UICollectionView
	fileprivate let componentProvider: ComponentProvider
	fileprivate var viewState: TempoSectionedViewState = InitialViewState()
	fileprivate var focusingIndexPath: IndexPath?
	fileprivate let reusableViewContainer: ReusableViewContainer
	fileprivate let dispatcher: Dispatcher?
	
	fileprivate struct InitialViewState: TempoSectionedViewState {
		var sections: [TempoViewStateItem] {
			return []
		}
	}
	
	// MARK: Init
	
	/// Initializes a CollectionViewAdapter
	///
	/// - Parameters:
	///   - collectionView: the collectionView that is being adapted to work with viewStates and components.
	///   - componentProvider: the componentProvider that returns a component based on a viewState.
	///   - reusableViewContainerType: the type of the ReusableViewContainer to use for managing reusable views.
	///   - dispatcher: a dispatcher can optionally be provided so that TempoEvent.CollectionViewUpdatesComplete event can be observed when the collectionView is done performing a batch update.
	public init(collectionView: UICollectionView, componentProvider: ComponentProvider, reusableViewContainerType: ReusableViewContainer.Type = ReusableCollectionViewContainer.self, dispatcher: Dispatcher? = nil) {
		self.collectionView = collectionView
		self.componentProvider = componentProvider
		self.reusableViewContainer = reusableViewContainerType.init(collectionView: collectionView)
		self.dispatcher = dispatcher
		super.init()
		
		componentProvider.registerComponents(reusableViewContainer)
		
		collectionView.dataSource = self
		collectionView.delegate = self
	}
	
	// MARK: Public Methods
	
	public func itemFor(_ indexPath: IndexPath) -> TempoViewStateItem {
		return viewState.item(for: indexPath)
	}
	
	public func supplementaryItemFor(_ indexPath: IndexPath) -> TempoViewStateItem {
		return viewState.supplementaryItem(for: indexPath)
	}
	
	public func sectionFor(_ section: Int) -> TempoViewStateItem {
		return viewState.sections[section]
	}
	
	public func componentFor(_ indexPath: IndexPath) -> ComponentType {
		let item = itemFor(indexPath)
		return componentProvider.componentFor(item)
	}
	
	public func componentFor(supplementaryViewAtIndexPath indexPath: IndexPath) -> SupplementaryComponent {
		let supplementaryItem = supplementaryItemFor(indexPath)
		return componentProvider.supplementaryComponentFor(supplementaryItem)
	}
	
	// MARK: Private Methods
	
	fileprivate func insertSection(_ section: Int) {
		collectionView.insertSections(IndexSet(integer: section))
	}
	
	fileprivate func deleteSection(_ section: Int) {
		collectionView.deleteSections(IndexSet(integer: section))
	}
	
	fileprivate func updateSection(_ fromSection: Int, fromViewState: TempoSectionedViewState, toSection: Int) {
		let section = fromViewState.sections[fromSection]
		
		for item in 0..<section.numberOfItems {
			let fromIndexPath = IndexPath(item: item, section: fromSection)
			let toIndexPath = IndexPath(item: item, section: toSection)
			itemInfoForIndexPath(fromIndexPath, fromViewState: fromViewState, toIndexPath: toIndexPath).configureView()
		}
	}
	
	fileprivate func updateSection(_ fromSection: Int, fromViewState: TempoSectionedViewState, toSection: Int, itemUpdates: [CollectionViewItemUpdate]) {
		for update in itemUpdates {
			switch update {
			case .delete(let item):
				collectionView.deleteItems(at: [IndexPath(item: item, section: fromSection)])
				
			case .insert(let item):
				collectionView.insertItems(at: [IndexPath(item: item, section: toSection)])
				
			case .update(let fromItem, let toItem):
				let fromIndexPath = IndexPath(item: fromItem, section: fromSection)
				let toIndexPath = IndexPath(item: toItem, section: toSection)
				itemInfoForIndexPath(fromIndexPath, fromViewState: fromViewState, toIndexPath: toIndexPath).configureView()
			}
		}
	}
	
	fileprivate func reloadSection(_ section: Int) {
		collectionView.reloadSections(IndexSet(integer: section))
	}
	
	fileprivate func focus(_ focus: TempoFocus) {
		guard focus.indexPath != focusingIndexPath else { // Scroll already in progress
			return
		}
		
		guard let attributes = collectionView.layoutAttributesForItem(at: focus.indexPath) else {
			return
		}
		
		let scrollPosition: UICollectionViewScrollPosition
		
		switch focus.position {
		case .centeredHorizontally:
			scrollPosition = .centeredHorizontally
			
		case .centeredVertically:
			scrollPosition = .centeredVertically
		}
		
		if collectionView.bounds.contains(attributes.frame) {
			// The item is already fully visible.
			didFocus(focus.indexPath, attributes: attributes)
		} else if focus.animated {
			// Track index path during animation. Reset in `scrollViewDidEndScrollingAnimation:`.
			focusingIndexPath = focus.indexPath
			collectionView.scrollToItem(at: focus.indexPath, at: scrollPosition, animated: true)
		} else {
			collectionView.scrollToItem(at: focus.indexPath, at: scrollPosition, animated: false)
			didFocus(focus.indexPath, attributes: attributes)
		}
	}
	
	fileprivate func updateHeader(_ fromSection: Int, fromViewState: TempoSectionedViewState, toSection: Int) {
		let indexPath = IndexPath(item: 0, section: fromSection)
		supplementaryInfo(for: indexPath).configureView()
	}
	
	fileprivate func itemInfoForIndexPath(_ indexPath: IndexPath) -> CollectionViewItemInfo {
		return itemInfoForIndexPath(indexPath, fromViewState: viewState, toIndexPath: indexPath)
	}
	
	fileprivate func itemInfoForIndexPath(_ fromIndexPath: IndexPath, fromViewState: TempoSectionedViewState, toIndexPath: IndexPath) -> CollectionViewItemInfo {
		let fromViewState = fromViewState.item(for: fromIndexPath)
		let toViewState = viewState.item(for: toIndexPath)
		let component = componentProvider.componentFor(toViewState)
		let container = reusableViewContainer.reusableViewItemContainer(fromIndexPath: fromIndexPath, toIndexPath: toIndexPath)
		
		return CollectionViewItemInfo(fromViewState: fromViewState,
		                              toViewState: toViewState,
		                              component: component,
		                              container: container)
	}
	
	fileprivate func supplementaryInfo(for indexPath: IndexPath) -> CollectionViewSupplementaryInfo {
		return supplementaryInfo(indexPath, fromViewState: viewState, toIndexPath: indexPath)
	}
	
	fileprivate func supplementaryInfo(_ fromIndexPath: IndexPath, fromViewState: TempoSectionedViewState, toIndexPath: IndexPath) -> CollectionViewSupplementaryInfo {
		let fromViewState = fromViewState.supplementaryItem(for: fromIndexPath)
		let toViewState = viewState.supplementaryItem(for: toIndexPath)
		let container = reusableViewContainer.reusableViewItemContainer(fromIndexPath: fromIndexPath, toIndexPath: toIndexPath)
		
		let supplementaryComponent = componentProvider.supplementaryComponentFor(toViewState)
		
		return CollectionViewSupplementaryInfo(fromViewState: fromViewState,
		                                       toViewState: toViewState,
		                                       supplementaryComponent: supplementaryComponent,
		                                       container: container)
	}
	
	fileprivate func didFocus(_ indexPath: IndexPath, attributes: UICollectionViewLayoutAttributes) {
		let itemInfo = itemInfoForIndexPath(indexPath)
		itemInfo.focusAccessibility()
		itemInfo.didFocus(attributes.frame, coordinateSpace: collectionView)
	}
}

// MARK: - SectionPresenterAdapter

extension CollectionViewAdapter: SectionPresenterAdapter {
	public func applyUpdates(_ updates: [CollectionViewSectionUpdate], viewState: TempoSectionedViewState) {
		let fromViewState = self.viewState
		self.viewState = viewState
		
		// Bail if there aren't any updates to apply.
		guard !updates.isEmpty else { return }
		
		// Bail unless the collection view has already been laid out. Since the collection view's
		// internal cache is updated when it's laid out, calling `performBatchUpdates` with deletes
		// or inserts before layout crashes with `NSInternalInconsistencyException`.
		guard collectionView.contentSize != .zero else { return }
		
		collectionView.performBatchUpdates({
			for update in updates {
				switch update {
				case .delete(let index):
					self.deleteSection(index)
				case .insert(let index):
					self.insertSection(index)
				case .reload(let index):
					self.reloadSection(index)
				case .update(let fromIndex, let toIndex, let itemUpdates):
					if itemUpdates.count > 0 {
						self.updateSection(fromIndex, fromViewState: fromViewState, toSection: toIndex, itemUpdates: itemUpdates)
					} else {
						self.updateSection(fromIndex, fromViewState: fromViewState, toSection: toIndex)
					}
				case .focus(let focus):
					self.focus(focus)
				case .header(let fromIndex, let toIndex):
					self.updateHeader(fromIndex, fromViewState: fromViewState, toSection: toIndex)
				}
			}
		}) { [weak self] _ in
			self?.dispatcher?.triggerEvent(TempoEvent.CollectionViewUpdatesComplete())
		}
	}
}

// MARK: - ComponentWrapper

public struct ComponentWrapper {
	public init(cell: UICollectionViewCell, view: UIView) {
		self.cell = cell
		self.view = view
	}
	
	var cell: UICollectionViewCell
	var view: UIView
}

// MARK: - ReusableViewContainer

public protocol ReusableViewContainer {
	init(collectionView: UICollectionView)
	
	func registerReusableView<T: UIView>(_ viewType: T.Type) where T: Reusable
	func registerReusableView<T: UIView>(_ viewType: T.Type, reuseIdentifier: String) where T: Reusable
	func registerReusableView<T: UIView>(_ viewType: T.Type, forSupplementaryViewOfKind kind: String) where T: Reusable
	func reusableViewItemContainer(fromIndexPath: IndexPath, toIndexPath: IndexPath) -> ReusableViewItemContainer
}

// MARK: - ReusableViewItemContainer

public protocol ReusableViewItemContainer {
	
	func dequeueReusableWrapper<T: UIView>(_ viewType: T.Type) -> ComponentWrapper where T: Reusable, T: Creatable
	func dequeueReusableWrapper<T: UIView>(_ viewType: T.Type, reuseIdentifier: String) -> ComponentWrapper where T: Reusable, T: Creatable
	func dequeueReusableWrapper<T: UIView>(_ viewType: T.Type, forSupplementaryViewOfKind kind: String) -> ComponentWrapper where T: Reusable, T: Creatable
	func visibleWrapper<T: UIView>(_ viewType: T.Type) -> ComponentWrapper? where T: Reusable
	func visibleWrapper<T: UIView>(_ viewType: T.Type, forSupplementaryViewOfKind kind: String) -> ComponentWrapper? where T: Reusable
}

public extension ReusableViewItemContainer {
	func dequeueReusableWrapper<T: UIView>(_ viewType: T.Type) -> ComponentWrapper where T: Reusable, T: Creatable {
		return dequeueReusableWrapper(viewType, reuseIdentifier: viewType.reuseID)
	}
}

// MARK: - CollectionViewItemInfo

private struct CollectionViewItemInfo {
	let fromViewState: TempoViewStateItem
	let toViewState: TempoViewStateItem
	let component: ComponentType
	let container: ReusableViewItemContainer
	
	var view: UIView? {
		return component.visibleWrapper(container, viewState: fromViewState)?.view
	}
	
	var cell: UICollectionViewCell {
		let wrapper = component.dequeueWrapper(container, viewState: toViewState)
		component.willDisplayItem(toViewState)
		component.prepareView(wrapper.view, viewState: toViewState)
		component.configureView(wrapper.view, viewState: toViewState)
		return wrapper.cell
	}
	
	func configureView() {
		if let view = view {
			component.willDisplayItem(toViewState)
			component.configureView(view, viewState: toViewState)
		}
	}
	
	func focusAccessibility() {
		if let view = view {
			component.focusAccessibility(view, viewState: toViewState)
		}
	}
	
	func shouldHighlightView() -> Bool {
		if let view = view {
			return component.shouldHighlightView(view, viewState: toViewState)
		} else {
			return shouldSelectView()
		}
	}
	
	func shouldSelectView() -> Bool {
		if let view = view {
			return component.shouldSelectView(view, viewState: toViewState)
		} else {
			return true
		}
	}
	
	func selectView() {
		if let view = view, shouldSelectView() {
			component.selectView(view, viewState: toViewState)
		}
	}
	
	func didFocus(_ frame: CGRect, coordinateSpace: UICoordinateSpace) {
		component.didFocus(frame, coordinateSpace: coordinateSpace, viewState: toViewState)
	}
}

// MARK: - CollectionViewSupplementaryInfo

private struct CollectionViewSupplementaryInfo {
	let fromViewState: TempoViewStateItem
	let toViewState: TempoViewStateItem
	let component: ComponentType
	let kind: String
	let container: ReusableViewItemContainer
	
	init(fromViewState: TempoViewStateItem, toViewState: TempoViewStateItem, supplementaryComponent: SupplementaryComponent, container: ReusableViewItemContainer) {
		self.fromViewState = fromViewState
		self.toViewState = toViewState
		self.component = supplementaryComponent.component
		self.kind = supplementaryComponent.kind
		self.container = container
	}
	
	var view: UIView? {
		return component.visibleWrapper(container, forSupplementaryViewOfKind: kind, viewState: fromViewState)?.view
	}
	
	var cell: UICollectionViewCell {
		let wrapper = component.dequeueWrapper(container, forSupplementaryViewOfKind: kind, viewState: toViewState)
		component.willDisplayItem(toViewState)
		component.prepareView(wrapper.view, viewState: toViewState)
		component.configureView(wrapper.view, viewState: toViewState)
		return wrapper.cell
	}
	
	func configureView() {
		if let view = view {
			component.willDisplayItem(toViewState)
			component.configureView(view, viewState: toViewState)
		}
	}
}

// MARK: - UICollectionViewDataSource

extension CollectionViewAdapter: UICollectionViewDataSource {
	public func numberOfSections(in collectionView: UICollectionView) -> Int {
		return viewState.sections.count
	}
	
	public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return viewState.sections[section].numberOfItems
	}
	
	public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		return itemInfoForIndexPath(indexPath).cell
	}
	
	public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		return supplementaryInfo(for: indexPath).cell
	}
}

// MARK: - UICollectionViewDelegate

extension CollectionViewAdapter: UICollectionViewDelegate {
	public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		itemInfoForIndexPath(indexPath).selectView()
	}
	
	public func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
		return itemInfoForIndexPath(indexPath).shouldHighlightView()
	}
	
	public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
		return itemInfoForIndexPath(indexPath).shouldSelectView()
	}
}

// MARK: - UIScrollViewDelegate

extension CollectionViewAdapter: UIScrollViewDelegate {
	public func scrollViewDidScroll(_ scrollView: UIScrollView) {
		scrollViewDelegate?.scrollViewDidScroll?(scrollView)
	}
	
	public func scrollViewDidZoom(_ scrollView: UIScrollView) {
		scrollViewDelegate?.scrollViewDidZoom?(scrollView)
	}
	
	public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		scrollViewDelegate?.scrollViewWillBeginDragging?(scrollView)
	}
	
	public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
		scrollViewDelegate?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
	}
	
	public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		scrollViewDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
	}
	
	public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
		scrollViewDelegate?.scrollViewWillBeginDecelerating?(scrollView)
	}
	
	public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		scrollViewDelegate?.scrollViewDidEndDecelerating?(scrollView)
	}
	
	public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
		if let indexPath = focusingIndexPath {
			focusingIndexPath = nil
			
			if let attributes = collectionView.layoutAttributesForItem(at: indexPath) {
				didFocus(indexPath, attributes: attributes)
			}
		}
		
		scrollViewDelegate?.scrollViewDidEndScrollingAnimation?(scrollView)
	}
	
	public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		return scrollViewDelegate?.viewForZooming?(in: scrollView)
	}
	
	public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
		scrollViewDelegate?.scrollViewWillBeginZooming?(scrollView, with: view)
	}
	
	public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
		scrollViewDelegate?.scrollViewDidEndZooming?(scrollView, with: view, atScale: scale)
	}
	
	public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
		return scrollViewDelegate?.scrollViewShouldScrollToTop?(scrollView) ?? true
	}
	
	public func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
		scrollViewDelegate?.scrollViewDidScrollToTop?(scrollView)
	}
}
