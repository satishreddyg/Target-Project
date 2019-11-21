//
//  DetailCoordinator.swift
//  ProductViewer
//
//  Created by Satish Garlapati on 11/16/19.
//  Copyright © 2019 Target. All rights reserved.
//

import Foundation
import Tempo

/*
 Coordinator for the product detail page.
 
 We can combine both coordinators if we have more common methods/functionality
 */
class DetailCoordinator: TempoCoordinator {
    // MARK: Presenters, view controllers, view state.
    
    var presenters = [TempoPresenterType]() {
        didSet { updateUI() }
    }
    
    private let viewState: DetailViewState
    let dispatcher = Dispatcher()
    
    /*
     presenter `present` method would ultimately lead to a UI presentation
     Not all present implementation would happen on main thread
     So, its better to run this on main queue from here itself
     Example: Section presenter `present` method would applyUpdates on main queue BUT
     - any other custom presenter's implementation may not have main queue
     */
    fileprivate func updateUI() {
        DispatchQueue.main.async {
            for presenter in self.presenters {
                guard let detailPresenter = presenter as? DetailPresenter else { continue }
                detailPresenter.presentItem(with: self.viewState.selectedItem)
            }
        }
    }
    
    lazy var viewController: DetailViewController = {
        return DetailViewController.getViewControllerFor(coordinator: self)
    }()
    
    // MARK: Init
    
    init(selectedItem: TempoViewStateItem) {
        viewState = DetailViewState(selectedItem: selectedItem)
        registerListeners()
    }
    
    // MARK: ListCoordinator
    
    fileprivate func registerListeners() {
        dispatcher.addObserver(UserInteraction.self) { [weak self] interaction in
            switch interaction.type {
            case .addToCart:
                self?.showAlert(with: "Adding to cart...", andMessage: "Successfully Added")
            case .addToList:
                self?.showAlert(with: "Adding to wishlist...", andMessage: "Successfully Added")
            default: break
            }
        }
    }
    
    /**
     presents alertController on main queue
    */
    private func showAlert(with title: String, andMessage message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction( UIAlertAction(title: "OK", style: .cancel, handler: nil) )
            self.viewController.present(alert, animated: true, completion: nil)
        }
    }
}

