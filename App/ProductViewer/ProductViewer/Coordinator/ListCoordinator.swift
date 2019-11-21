//
//  ListCoordinator.swift
//  ProductViewer
//
//  Created by Erik.Kerber on 8/18/16.
//  Copyright © 2016 Target. All rights reserved.
//

import Foundation
import Tempo

/*
 Coordinator for the product list
 */
class ListCoordinator: TempoCoordinator {
    
    // MARK: Presenters, view controllers, view state.
    
    var presenters = [TempoPresenterType]() {
        didSet {
            updateUI()
        }
    }
    
    // open for unit testing
    var viewState: ListViewState {
        didSet {
            updateUI()
        }
    }
    
    /*
     presenter `present` method would ultimately lead to a UI presentation
     Not all present implementation would happen on main thread
     So, its better to run this on main queue from here itself
     Example: Section presenter `present` method would applyUpdates on main queue BUT
     - any other custom presenter's implementation may not have main queue
     */
    
    fileprivate func updateUI() {
        // we don't have to capture self here as the closure is immediately executed with delayed deallocation.
        DispatchQueue.main.async {
            for presenter in self.presenters {
                presenter.present(self.viewState)
            }
        }
    }
    
    let dispatcher = Dispatcher()
    
    lazy var viewController: ListViewController = {
        return ListViewController.viewControllerFor(coordinator: self)
    }()
    
    // MARK: Init
    
    required init() {
        viewState = ListViewState(listItems: [])
        fetchDealsToUpdateState()
        registerListeners()
    }
    
    // MARK: ListCoordinator
    
    fileprivate func registerListeners() {
        dispatcher.addObserver(UserInteraction.self) { [weak self] interaction in
            switch interaction.type {
            case .selectedListItem(let item):
                DispatchQueue.main.async {
                    self?.presentDetailView(for: item)
                }
            default: break
            }
        }
    }
    
    private func presentDetailView(for item: TempoViewStateItem) {
        let detailCoordinator = DetailCoordinator(selectedItem: item)
        let detailViewController = detailCoordinator.viewController
        viewController.navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    /*
     call global queue with qos `userInitiated` as user is prevented from actively using your app until results are returned
    */
    private func fetchDealsToUpdateState() {
        // we can add indicator view or any other app specific spinners while API call's are in place
        DispatchQueue.global(qos: .userInitiated).async {
            NetworkManager.shared.fetchDeals { [weak self] (response, error) in
                guard let targetResponse = response else {
                    //handle error scenario
                    self?.viewState.listItems = []
                    return
                }
                self?.viewState.listItems = targetResponse.deals
            }
        }
    }
}
