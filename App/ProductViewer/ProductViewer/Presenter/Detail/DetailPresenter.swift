//
//  DetailPresenter.swift
//  ProductViewer
//
//  Created by Satish Garlapati on 11/17/19.
//  Copyright © 2019 Target. All rights reserved.
//

import Foundation
import Tempo

class DetailPresenter: TempoPresenter {
    let detailView: DetailView
    let dispatcher: Dispatcher
    
    init(view: DetailView, dispatcher: Dispatcher) {
        self.detailView = view
        self.dispatcher = dispatcher
    }
    
    func presentItem(with viewStateItem: TempoViewStateItem) {
        guard let item = viewStateItem as? TargetItem else { return }
        detailView.detailImageView.setImage(withUrlString: item.imageUrl, withKey: item.guid)
        detailView.priceLabel.text = item.price
        detailView.descriptionLabel.text = item.itemDescription
        detailView.addToCartButton.backgroundColor = HarmonyColor.targetBullseyeRedColor
        
        // I was doing addTarget here in `presenter` itself after going through provided `Tempo` documentation
        detailView.addToCartButton.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
        detailView.addToListButton.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
        // BUT if this is not required, we can add IBAction methods to the view itself and trigger dispatch events from view itself - this is an alternative
    }
    
    /*
     Instead of switching on element tag's, we can also write individual method's for separation of concerns
     but here its only two separate actions just to trigger event so, I went with tag's
    */
    @objc private func buttonAction(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            dispatcher.triggerEvent(UserInteraction(type: .addToCart))
        case 1:
            dispatcher.triggerEvent(UserInteraction(type: .addToList))
        default: break
        }
    }
}

// extending TempoPresenter to extend the functionality for selected viewStateItem as well
extension TempoPresenter {
    func presentItem(with viewStateItem: TempoViewStateItem) {
        if let viewState = viewStateItem as? Self.ViewState {
            present(viewState)
        }
    }
}

protocol DetailPresenterType: TempoPresenterType {
    func presentItem(with viewStateItem: TempoViewStateItem)
}
