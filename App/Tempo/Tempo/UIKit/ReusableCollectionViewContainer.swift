//
//  ReusableCollectionViewContainer.swift
//  HarmonyKit
//
//  Created by Erik.Kerber on 2/20/17.
//  Copyright © 2017 Target. All rights reserved.
//

import Foundation

struct ReusableCollectionViewContainer: ReusableViewContainer {
    
    let collectionView: UICollectionView
    
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
    }
    
    public func registerReusableView<T: UIView>(_ viewType: T.Type) where T: Reusable {
        collectionView.registerWrappedReusable(viewType)
    }
    
    public func registerReusableView<T: UIView>(_ viewType: T.Type, reuseIdentifier: String) where T: Reusable {
        collectionView.registerWrappedReusable(viewType, reuseIdentifier: reuseIdentifier)
    }
    
    public func registerReusableView<T: UIView>(_ viewType: T.Type, forSupplementaryViewOfKind kind: String) where T: Reusable {
        collectionView.registerWrappedReusable(viewType, forSupplementaryViewOfKind: kind)
    }
    
    func reusableViewItemContainer(fromIndexPath: IndexPath, toIndexPath: IndexPath) -> ReusableViewItemContainer {
        return ReusableCollectionViewItemContainer(fromIndexPath: fromIndexPath, toIndexPath: toIndexPath, collectionView: collectionView)
    }
}

// MARK: - ReusableCollectionViewItemContainer

private struct ReusableCollectionViewItemContainer: ReusableViewItemContainer {
    
    var fromIndexPath: IndexPath
    var toIndexPath: IndexPath
    var collectionView: UICollectionView
    
    init(fromIndexPath: IndexPath, toIndexPath: IndexPath, collectionView: UICollectionView) {
        self.fromIndexPath = fromIndexPath
        self.toIndexPath = toIndexPath
        self.collectionView = collectionView
    }
        
    func dequeueReusableWrapper<T: UIView>(_ viewType: T.Type, reuseIdentifier: String) -> ComponentWrapper where T: Reusable, T: Creatable {
        let cell = collectionView.dequeueWrappedReusable(viewType, reuseIdentifier: reuseIdentifier, indexPath: toIndexPath)
        return ComponentWrapper(cell: cell, view: cell.reusableView)
    }
    
    func dequeueReusableWrapper<T: UIView>(_ viewType: T.Type, forSupplementaryViewOfKind kind: String) -> ComponentWrapper where T: Reusable, T: Creatable {
        let cell = collectionView.dequeueWrappedReusable(viewType, forSupplementaryViewOfKind: kind, indexPath: toIndexPath)
        return ComponentWrapper(cell: cell, view: cell.reusableView)
    }
    
    func visibleWrapper<T: UIView>(_ viewType: T.Type) -> ComponentWrapper? where T: Reusable {
        guard let cell = collectionView.cellForItem(at: fromIndexPath) as? CollectionViewWrapperCell<T> else {
            return nil
        }
        
        return ComponentWrapper(cell: cell, view: cell.reusableView)
    }
    
    func visibleWrapper<T: UIView>(_ viewType: T.Type, forSupplementaryViewOfKind kind: String) -> ComponentWrapper? where T: Reusable {
        guard let cell = collectionView.supplementaryView(forElementKind: kind, at: fromIndexPath) as? CollectionViewWrapperCell<T> else {
            return nil
        }
        
        return ComponentWrapper(cell: cell, view: cell.reusableView)
    }
}
