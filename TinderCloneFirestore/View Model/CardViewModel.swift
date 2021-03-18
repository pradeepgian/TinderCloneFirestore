//
//  CardViewModel.swift
//  TinderCloneFirestore
//
//  Created by Pradeep Gianchandani on 19/11/20.
//

import UIKit

protocol ProducesCardViewModel {
    func toCardViewModel() -> CardViewModel
}

class CardViewModel {
    
    let imageUrls: [String]
    let attributedString: NSAttributedString
    let textAlignment: NSTextAlignment
    
    init(imageNames: [String], attributedString: NSAttributedString, textAlignment: NSTextAlignment) {
        self.imageUrls = imageNames
        self.attributedString = attributedString
        self.textAlignment = textAlignment
    }
    
    //whenever we modify the image index, we can fire imageIndexObserver
    fileprivate var imageIndex = 0 {
        didSet {
            let imageUrl = imageUrls[imageIndex]
//            let image = UIImage(named: imageName)
            imageIndexObserver?(imageIndex, imageUrl)
        }
    }
    
    // Reactive Programming
    // Here you expose the property on View Model Object
    // such that you can notify an external class - here CardView
    // Here you will notify the index change of images
    var imageIndexObserver: ((Int, String?) -> ())?
    
    func advanceToNextPhoto() {
        imageIndex = min(imageIndex + 1, imageUrls.count - 1)
    }
    
    func goToPreviousPhoto() {
        imageIndex = max(0, imageIndex - 1)
    }
    
}
