//
//  MessagesController.swift
//  TinderCloneFirestore
//
//  Created by Pradeep Gianchandani on 04/04/21.
//

import LBTATools

class MessagesController: LBTAListController<MatchCell, UIColor>, UICollectionViewDelegateFlowLayout {
    
    let customNavBar = MatchesNavBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        items = [
            .red,
            .blue,
            .green,
            .purple,
            .orange
        ]
        
        collectionView.backgroundColor = .white
        
        customNavBar.backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        
        view.addSubview(customNavBar)
        customNavBar.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, size: .init(width: 0, height: 150))
        
        // set 150 points spacing from the top so that cells dont hide behind custom nav bar
        collectionView.contentInset.top = 150
    }
    
    @objc fileprivate func handleBack() {
        navigationController?.popViewController(animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: 100, height: 120)
    }
}

class MatchCell: LBTAListCell<UIColor> {
    
    let profileImageView: UIImageView = UIImageView(image: #imageLiteral(resourceName: "2080ti"), contentMode: .scaleAspectFill)
    let usernameLabel = UILabel(text: "Username Here", font: .systemFont(ofSize: 14, weight: .semibold), textColor: #colorLiteral(red: 0.2099210322, green: 0.209956944, blue: 0.2099131644, alpha: 1), textAlignment: .center, numberOfLines: 2)
    
    override var item: UIColor! {
        didSet {
            backgroundColor = item
        }
    }
    
    override func setupViews() {
        super.setupViews()
        
        profileImageView.clipsToBounds = true
        profileImageView.constrainWidth(80)
        profileImageView.constrainHeight(80)
        profileImageView.layer.cornerRadius = 80 / 2
        
//        stack(stack(profileImageView, alignment: .center), usernameLabel)
        stack(profileImageView, usernameLabel, alignment: .center)
    }
}
