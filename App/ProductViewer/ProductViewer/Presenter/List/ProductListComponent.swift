//
//  ProductListComponent.swift
//  ProductViewer
//
//  Created by Erik.Kerber on 8/18/16.
//  Copyright © 2016 Target. All rights reserved.
//

import Tempo

struct ProductListComponent: Component {
    var dispatcher: Dispatcher?
    
    /*
     ConfigureView make sense to configure the elements with values rather than prepareView func
     Moreover, Component protocol didn't had enough information on which method does what
    */
    func configureView(_ view: ProductListView, item: TargetItem) {
        view.titleLabel.text = item.title
        view.priceLabel.text = item.price
        view.productImage.setImage(withUrlString: item.imageUrl, withKey: item.guid)
    }
    
    func selectView(_ view: ProductListView, item: TargetItem) {
        dispatcher?.triggerEvent(UserInteraction(type: .selectedListItem(item)))
    }
}

extension ProductListComponent: HarmonyLayoutComponent {
    /*
     We can set height either inside out or outside in
     we are going with constant height in this case becoz
     - supports detail view for each item
     - uniformity through the list view
    */
    func heightForLayout(_ layout: HarmonyLayout, item: TempoViewStateItem, width: CGFloat) -> CGFloat {
        return 150.0
    }
}
