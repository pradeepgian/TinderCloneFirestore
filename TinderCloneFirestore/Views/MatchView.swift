//
//  MatchView.swift
//  TinderCloneFirestore
//
//  Created by Pradeep Gianchandani on 01/04/21.
//

import UIKit

class MatchView: UIView {

    fileprivate let currentUserImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "maingearPC"))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.white.cgColor
        return imageView
    }()
    
    fileprivate let cardUserImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "2080ti"))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.white.cgColor
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupBlurView()
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    fileprivate func setupBlurView() {
        addSubview(visualEffectView)
        visualEffectView.fillSuperview()
        
        // Here we hide the view before presenting the match view
        // Then we animate the view and unhide it by setting its alpha as 1
        visualEffectView.alpha = 0
        visualEffectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapDismiss)))
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            // set its alpha to 1
            self.visualEffectView.alpha = 1
        }) { (_) in
            
        }
    }
    
    @objc fileprivate func handleTapDismiss() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.alpha = 0
        }) { (_) in
            self.removeFromSuperview()
        }
    }
    
    fileprivate func setupLayout() {
        addSubview(currentUserImageView)
        addSubview(cardUserImageView)
        
        let imageWidth: CGFloat = 140
        
        currentUserImageView.anchor(top: nil, leading: nil, bottom: nil, trailing: centerXAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 16), size: .init(width: imageWidth, height: imageWidth))
        currentUserImageView.layer.cornerRadius = imageWidth / 2
        currentUserImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        cardUserImageView.anchor(top: nil, leading: centerXAnchor, bottom: nil, trailing: nil, padding: .init(top: 0, left: 16, bottom: 0, right: 0), size: .init(width: imageWidth, height: imageWidth))
        cardUserImageView.layer.cornerRadius = imageWidth / 2
        cardUserImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
}
