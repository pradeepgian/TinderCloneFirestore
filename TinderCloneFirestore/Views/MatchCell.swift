//
//  MatchCell.swift
//  TinderCloneFirestore
//
//  Created by Pradeep Gianchandani on 09/04/21.
//

import LBTATools

class MatchCell: LBTAListCell<Match> {
    
    let profileImageView: UIImageView = UIImageView(image: #imageLiteral(resourceName: "top_left_profile"), contentMode: .scaleAspectFill)
    let usernameLabel = UILabel(text: "Username Here", font: .systemFont(ofSize: 14, weight: .semibold), textColor: #colorLiteral(red: 0.2099210322, green: 0.209956944, blue: 0.2099131644, alpha: 1), textAlignment: .center, numberOfLines: 2)
    
    override var item: Match! {
        didSet {
            usernameLabel.text = item.name
            profileImageView.sd_setImage(with: URL(string: item.profileImageUrl))
        }
    }
    
    override func setupViews() {
        super.setupViews()
        
        profileImageView.clipsToBounds = true
        profileImageView.constrainWidth(80)
        profileImageView.constrainHeight(80)
        profileImageView.layer.cornerRadius = 80 / 2
        
        stack(stack(profileImageView, alignment: .center), usernameLabel)
    }
}
