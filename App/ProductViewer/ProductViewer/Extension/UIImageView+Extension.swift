//
//  UIImageView.swift
//  ProductViewer
//
//  Created by Satish Garlapati on 11/17/19.
//  Copyright © 2019 Target. All rights reserved.
//

import UIKit

extension UIImageView {
    // cache the images for performance improvement
    static let imageCache = NSCache<NSString, UIImage>()
    
    // keep download image func separate from setImage as both functionalities are different
    public func setImage(withUrlString urlString: String, withKey key: String) {
        guard let cachedImage = UIImageView.imageCache.object(forKey: NSString(string: key)) else {
            downloadImage(from: urlString, withKey: key)
            return
        }
        image = cachedImage
    }
    
    // Assuming placeholder is a single image all through the app.
    // Should open up the setImage func if passing through is needed
    // if needed, we can also add an indicatorView for imageView while downloading is in progress - conveys that a image is loading for the user
    /**
     downloads new image from given urlString
     */
    private func downloadImage(from urlString: String, withKey key: String, placeHolderImage defaultImage: UIImage? = UIImage(named: "placeHolder")) {
        guard let url = URL(string: urlString) else {
            image = defaultImage
            return
        }
        // we can go with default qos here as user is not blocked or not dependent on this response
        DispatchQueue.global().async {
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
                DispatchQueue.main.async {
                    guard let data = data, error == nil else {
                        self.image = defaultImage
                        return
                    }
                    if let _image = UIImage(data: data) {
                        self.image = _image
                        UIImageView.imageCache.setObject(_image, forKey: NSString(string: key))
                    } else {
                        self.image = defaultImage
                    }
                }
            }).resume()
        }
    }
    
    /*
     We can do the same download with Data(contentsOf:) as well but one thing to note is,
     - Data(contentsOf:) method will download the contents of the url synchronously in the same thread the code is being executed
     so we should not invoke this on main thread
    */
}
