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
    
    let imageName: String
    let attributedString: NSAttributedString
    let textAlignment: NSTextAlignment
    
    init(imageName: String, attributedString: NSAttributedString, textAlignment: NSTextAlignment) {
        self.imageName = imageName
        self.attributedString = attributedString
        self.textAlignment = textAlignment
    }
    
}
