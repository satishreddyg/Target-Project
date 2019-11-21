//
//  DetailViewController.swift
//  ProductViewer
//
//  Created by Satish Garlapati on 11/16/19.
//  Copyright © 2019 Target. All rights reserved.
//

import UIKit
import Tempo

class DetailViewController: UIViewController {
    
    private var coordinator: TempoCoordinator!
    
    class func getViewControllerFor(coordinator: TempoCoordinator) -> DetailViewController {
        let viewController = DetailViewController()
        viewController.coordinator = coordinator
        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "details"
        // nib is not dynamically created so we can force cast to desired view
        // any crash would help us to correct it at build time itself
        let detailView = Bundle.main.loadNibNamed(DetailView.identifier, owner: self)?.first as! DetailView
        coordinator.presenters = [ DetailPresenter(view: detailView, dispatcher: coordinator.dispatcher) ]
    }
}
