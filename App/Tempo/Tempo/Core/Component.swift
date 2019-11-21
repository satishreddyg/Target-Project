//
//  Component.swift
//  HarmonyKit
//
//  Created by Ryan.Sander on 11/4/15.
//  Copyright © 2015 Target. All rights reserved.
//

import Foundation

public protocol ComponentType {
	var dispatcher: Dispatcher? { get set }
	
	func canDisplayItem(_ item: TempoViewStateItem) -> Bool
	func willDisplayItem(_ item: TempoViewStateItem)
	
	func prepareView(_ view: UIView, viewState: TempoViewStateItem)
	func configureView(_ view: UIView, viewState: TempoViewStateItem)
	func selectView(_ view: UIView, viewState: TempoViewStateItem)
	func shouldSelectView(_ view: UIView, viewState: TempoViewStateItem) -> Bool
	func shouldHighlightView(_ view: UIView, viewState: TempoViewStateItem) -> Bool
	func didFocus(_ frame: CGRect?, coordinateSpace: UICoordinateSpace?, viewState: TempoViewStateItem)
	func focusAccessibility(_ view: UIView, viewState: TempoViewStateItem)
	
	func registerWrapper(_ container: ReusableViewContainer)
	func registerWrapper(_ container: ReusableViewContainer, forSupplementaryViewOfKind kind: String)
	
	func dequeueWrapper(_ container: ReusableViewItemContainer, viewState: TempoViewStateItem) -> ComponentWrapper
	func dequeueWrapper(_ container: ReusableViewItemContainer, forSupplementaryViewOfKind kind: String, viewState: TempoViewStateItem) -> ComponentWrapper
	
	func visibleWrapper(_ container: ReusableViewItemContainer, viewState: TempoViewStateItem) -> ComponentWrapper?
	func visibleWrapper(_ container: ReusableViewItemContainer, forSupplementaryViewOfKind kind: String, viewState: TempoViewStateItem) -> ComponentWrapper?
}

public extension ComponentType {
	func willDisplayItem(_ item: TempoViewStateItem) { }
	func prepareView(_ view: UIView, viewState: TempoViewStateItem) { }
	func selectView(_ view: UIView, viewState: TempoViewStateItem) { }
	func shouldSelectView(_ view: UIView, viewState: TempoViewStateItem) -> Bool { return true }
	func shouldHighlightView(_ view: UIView, viewState: TempoViewStateItem) -> Bool { return shouldSelectView(view, viewState: viewState) }
	func didFocus(_ frame: CGRect?, coordinateSpace: UICoordinateSpace?, viewState: TempoViewStateItem) { }
	func focusAccessibility(_ view: UIView, viewState: TempoViewStateItem) { }
}

public protocol Component: ComponentType {
	associatedtype Item: TempoViewStateItem
	associatedtype View: UIView
	
	func willDisplayItem(_ item: Item)
	func prepareView(_ view: View, item: Item)
	func configureView(_ view: View, item: Item)
	func selectView(_ view: View, item: Item)
	func shouldSelectView(_ view: View, item: Item) -> Bool
	func shouldHighlightView(_ view: View, item: Item) -> Bool
	func didFocus(_ frame: CGRect?, coordinateSpace: UICoordinateSpace?, item: Item)
	func focusAccessibility(_ view: View, item: Item)
	
	func dequeueWrapper(_ container: ReusableViewItemContainer, item: Item) -> ComponentWrapper
	func dequeueWrapper(_ container: ReusableViewItemContainer, forSupplementaryViewOfKind kind: String, item: Item) -> ComponentWrapper
	
	func visibleWrapper(_ container: ReusableViewItemContainer, item: Item) -> ComponentWrapper?
	func visibleWrapper(_ container: ReusableViewItemContainer, forSupplementaryViewOfKind kind: String, item: Item) -> ComponentWrapper?
}

public extension Component {
	func willDisplayItem(_ item: Item) { }
	func prepareView(_ view: View, item: Item) { }
	func selectView(_ view: View, item: Item) { }
	func shouldSelectView(_ view: View, item: Item) -> Bool { return true }
	func shouldHighlightView(_ view: View, item: Item) -> Bool { return shouldSelectView(view, item: item) }
	func didFocus(_ frame: CGRect?, coordinateSpace: UICoordinateSpace?, item: Item) { }
	func focusAccessibility(_ view: View, item: Item) { }
}

public extension ComponentType where Self: Component {
	func withSpecificView<T>(_ view: UIView, viewState: TempoViewStateItem, perform: (View, Item) -> T) -> T {
		return perform(view as! Self.View, viewState as! Self.Item)
	}
	
	func canDisplayItem(_ item: TempoViewStateItem) -> Bool {
		return item is Item
	}
	
	func willDisplayItem(_ item: TempoViewStateItem) {
		willDisplayItem(item as! Item)
	}
	
	func prepareView(_ view: UIView, viewState: TempoViewStateItem) {
		withSpecificView(view, viewState: viewState) { view, item in
			prepareView(view, item: item)
		}
	}
	
	func configureView(_ view: UIView, viewState: TempoViewStateItem) {
		withSpecificView(view, viewState: viewState) { view, item in
			configureView(view, item: item)
		}
	}
	
	func selectView(_ view: UIView, viewState: TempoViewStateItem) {
		withSpecificView(view, viewState: viewState) { view, item in
			selectView(view, item: item)
		}
	}
	
	func shouldSelectView(_ view: UIView, viewState: TempoViewStateItem) -> Bool {
		return withSpecificView(view, viewState: viewState) { view, item in
			return shouldSelectView(view, item: item)
		}
	}
	
	func shouldHighlightView(_ view: UIView, viewState: TempoViewStateItem) -> Bool {
		return withSpecificView(view, viewState: viewState) { view, item in
			return shouldHighlightView(view, item: item)
		}
	}
	
	func didFocus(_ frame: CGRect?, coordinateSpace: UICoordinateSpace?, viewState: TempoViewStateItem) {
		didFocus(frame, coordinateSpace: coordinateSpace, item: viewState as! Self.Item)
	}
	
	func focusAccessibility(_ view: UIView, viewState: TempoViewStateItem) {
		withSpecificView(view, viewState: viewState) { view, item in
			focusAccessibility(view, item: item)
		}
	}
	
	func dequeueWrapper(_ container: ReusableViewItemContainer, viewState: TempoViewStateItem) -> ComponentWrapper {
		return dequeueWrapper(container, item: viewState as! Self.Item)
	}
	
	func dequeueWrapper(_ container: ReusableViewItemContainer, forSupplementaryViewOfKind kind: String, viewState: TempoViewStateItem) -> ComponentWrapper {
		return dequeueWrapper(container, forSupplementaryViewOfKind: kind, item: viewState as! Self.Item)
	}
	
	func visibleWrapper(_ container: ReusableViewItemContainer, viewState: TempoViewStateItem) -> ComponentWrapper? {
		return visibleWrapper(container, item: viewState as! Self.Item)
	}
	
	func visibleWrapper(_ container: ReusableViewItemContainer, forSupplementaryViewOfKind kind: String, viewState: TempoViewStateItem) -> ComponentWrapper? {
		return visibleWrapper(container, forSupplementaryViewOfKind: kind, item: viewState as! Self.Item)
	}
}

public extension Component where View: Reusable, View: Creatable {
	func registerWrapper(_ container: ReusableViewContainer) {
		container.registerReusableView(View.self)
	}
	
	func registerWrapper(_ container: ReusableViewContainer, forSupplementaryViewOfKind kind: String) {
		container.registerReusableView(View.self, forSupplementaryViewOfKind: kind)
	}
	
	func dequeueWrapper(_ container: ReusableViewItemContainer, item: Item) -> ComponentWrapper {
		return container.dequeueReusableWrapper(View.self)
	}
	
	func dequeueWrapper(_ container: ReusableViewItemContainer, forSupplementaryViewOfKind kind: String, item: Item) -> ComponentWrapper {
		return container.dequeueReusableWrapper(View.self, forSupplementaryViewOfKind: kind)
	}
	
	func visibleWrapper(_ container: ReusableViewItemContainer, item: Item) -> ComponentWrapper? {
		return container.visibleWrapper(View.self)
	}
	
	func visibleWrapper(_ container: ReusableViewItemContainer, forSupplementaryViewOfKind kind: String, item: Item) -> ComponentWrapper? {
		return container.visibleWrapper(View.self, forSupplementaryViewOfKind: kind)
	}
}
