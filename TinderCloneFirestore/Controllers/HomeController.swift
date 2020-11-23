//
//  ViewController.swift
//  TinderCloneFirestore
//
//  Created by Pradeep Gianchandani on 19/11/20.
//

import UIKit

class HomeController: UIViewController {
    
    let cardViewModels: [CardViewModel] = {
        let producers = [
        User(name: "Corsair", age: 2, profession: "Gaming PC", imageName: "pc1"),
        User(name: "Main Gear", age: 1, profession: "Editing PC", imageName: "maingearPC"),
        Advertiser(title: "GTX 2080Ti", brandName: "Nvidia", posterPhotoName: "2080ti")
        ] as [ProducesCardViewModel]
        
        let viewModels = producers.map({return $0.toCardViewModel()})
        return viewModels
    }()
    
    let topStackView = TopNavigationStackView()
    let cardsDeckView = UIView()
    let buttonStackView = HomeBottomControlsStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupLayout()
        setupDummyCards()
    }

    // MARK:- Fileprivate
    fileprivate func setupLayout() {
        //add topview, middle view and bottom view in vertical stack
        let overallStackview = UIStackView(arrangedSubviews: [topStackView, cardsDeckView, buttonStackView])
        overallStackview.axis = .vertical
        view.addSubview(overallStackview)
        
        //set the top, right, left and bottom spacing to 0 with respect to home view
        //set the top and bottom anchor within the safe area so that there are layout issues in full screen iPhones (with a notch) like iPhone X family
        overallStackview.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor)
        
        //Set the margin on left and right of stack view
        overallStackview.isLayoutMarginsRelativeArrangement = true
        overallStackview.layoutMargins = .init(top: 0, left: 12, bottom: 0, right: 12)
        
        //when you add items to stack, view on first index will be at the bottom and last view will be on the top
        //when you move the carddeckview (with the help of pan gesture), it goes behind the bottomview, hence we move it to front so that its z-position is the top index
        overallStackview.bringSubviewToFront(cardsDeckView)
    }
    
    fileprivate func setupDummyCards() {
        cardViewModels.forEach { (cardViewModel) in
            let cardView = CardView()
            cardView.cardViewModel = cardViewModel
            
            cardsDeckView.addSubview(cardView)
            cardView.fillSuperview()
        }
    }

}

