//
//  HomeBottomControlsStackView.swift
//  TinderCloneFirestore
//
//  Created by Pradeep Gianchandani on 19/11/20.
//

import UIKit

class HomeBottomControlsStackView: UIStackView {
    
    static func createButton(image: UIImage) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        return button
    }

    let refreshButton = createButton(image: #imageLiteral(resourceName: "refresh_circle"))
    let dislikeButton = createButton(image: #imageLiteral(resourceName: "dismiss_circle"))
    let superLikeButton = createButton(image: #imageLiteral(resourceName: "super_like_circle"))
    let likeButton = createButton(image: #imageLiteral(resourceName: "like_circle"))
    let specialButton = createButton(image: #imageLiteral(resourceName: "boost_circle"))

    override init(frame: CGRect) {
        super.init(frame: frame)
        //Here we don't set the axis since it is horizontal by default
        distribution = .fillEqually
        heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        [refreshButton, dislikeButton, superLikeButton, likeButton, specialButton].forEach { (button) in
            self.addArrangedSubview(button)
        }
        
//        let subviews = [#imageLiteral(resourceName: "refresh_circle"), #imageLiteral(resourceName: "dismiss_circle"), #imageLiteral(resourceName: "super_like_circle"), #imageLiteral(resourceName: "like_circle"), #imageLiteral(resourceName: "boost_circle")].map { (image) -> UIView in
//            let button = UIButton(type: .system)
//            button.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
//            return button
//        }
//
//        subviews.forEach { (v) in
//            addArrangedSubview(v)
//        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
