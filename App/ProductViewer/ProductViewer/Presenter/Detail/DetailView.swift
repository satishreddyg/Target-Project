//
//  DetailView.swift
//  ProductViewer
//
//  Created by Satish Garlapati on 11/16/19.
//  Copyright © 2019 Target. All rights reserved.
//

import UIKit
import Tempo

/*
 All these UI components can be build programmatically and that's what I prefer
 But, I did through xib considering time sensitivity
 */

// I added the elements in stackView inside a scrollView to make sure components are not compromised in size But if we want static views then we can remove scrollView and go with stackView and make the views adjust their size by their content by using contentHugging and content compression resistence priorities
class DetailView: UIView {
    @IBOutlet weak var detailImageView: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var addToCartButton: UIButton!
    @IBOutlet weak var addToListButton: UIButton!
    
    static var identifier: String {
        return String(describing: self)
    }
}
