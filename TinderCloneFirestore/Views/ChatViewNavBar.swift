//
//  MessagesNavBar.swift
//  TinderCloneFirestore
//
//  Created by Pradeep Gianchandani on 05/04/21.
//

import LBTATools

class ChatViewNavBar: UIView {
    
    let userProfileImageView = CircularImageView(width: 44, image: #imageLiteral(resourceName: "photo_placeholder"))
    let nameLabel = UILabel(text: "USERNAME", font: .systemFont(ofSize: 16))
    
    let backButton = UIButton(image: #imageLiteral(resourceName: "back").withRenderingMode(.alwaysOriginal))
    let flagButton = UIButton(image: #imageLiteral(resourceName: "flag").withRenderingMode(.alwaysOriginal))
    
    fileprivate let match: Match
    
    init(match: Match) {
        self.match = match
        
        nameLabel.text = match.name
        userProfileImageView.sd_setImage(with: URL(string: match.profileImageUrl))
        
        super.init(frame: .zero)
        backgroundColor = .white
        
        setupShadow(opacity: 0.2, radius: 8, offset: .init(width: 0, height: 10), color: .init(white: 0, alpha: 0.3))
        
        
        // another way of implementing this would have been horizontally centering the vertical stack view
        // vstack and hstack helps in implementing this faster
        // Here embeding components in hstack will expand the stack view horizontally and compact it vertically
        // hence nameLabel height is auto adjusted as per its content
        let middleStack =  hstack(
            stack(userProfileImageView, nameLabel, spacing: 8, alignment: .center),
            alignment: .center
        )
        
//        let middleStack = stack(userProfileImageView, nameLabel, spacing: 8, alignment: .center)
        
        hstack(backButton.withWidth(50),
               middleStack,
               flagButton).withMargins(.init(top: 0, left: 4, bottom: 0, right: 16))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
