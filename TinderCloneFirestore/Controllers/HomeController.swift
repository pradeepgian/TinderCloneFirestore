//
//  ViewController.swift
//  TinderCloneFirestore
//
//  Created by Pradeep Gianchandani on 19/11/20.
//

import UIKit
import Firebase
import JGProgressHUD

class HomeController: UIViewController {
    
    var cardViewModels = [CardViewModel]()
    let topStackView = TopNavigationStackView()
    let cardsDeckView = UIView()
    let bottomControlsStackView = HomeBottomControlsStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        topStackView.settingsButton.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)
        bottomControlsStackView.refreshButton.addTarget(self, action: #selector(handleRefresh), for: .touchUpInside)
        
        setupLayout()
        setupFirestoreUserCards()
        fetchUsersFromFirestore()
    }

    // MARK:- Fileprivate
    fileprivate func setupLayout() {
        view.backgroundColor = .white

        //add topview, middle view and bottom view in vertical stack
        let overallStackview = UIStackView(arrangedSubviews: [topStackView, cardsDeckView, bottomControlsStackView])
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
    
    fileprivate func setupFirestoreUserCards() {
        cardViewModels.forEach { (cardViewModel) in
            let cardView = CardView()
            cardView.cardViewModel = cardViewModel
            
            cardsDeckView.addSubview(cardView)
            cardView.fillSuperview()
        }
    }

    @objc func handleSettings() {
        print("Show registration page")
        let registrationController = RegistrationController()
        registrationController.modalPresentationStyle = .fullScreen
        present(registrationController, animated: true)
    }
    
    var lastFetchedUser: User?
    
    fileprivate func fetchUsersFromFirestore() {
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Fetching Users"
        hud.show(in: view)
        
        // This query will call the collection of user and you will get documents
        // Firestore provides a query functionality for specifying which documents you want to retrieve from a collection or collection group
        // Check below link for more details
        // https://firebase.google.com/docs/firestore/query-data/queries
        //This query introduces pagination to page through 2 users at a time
        //Here we set the last fetched user while fetching all documents
        //lastFetchedUser is passed while hitting pagination query
        let query = Firestore.firestore().collection("users").order(by: "uid").start(after: [lastFetchedUser?.uid ?? ""]).limit(to: 2)
        query.getDocuments { (snapshot, error) in
            hud.dismiss()
            
            if let error = error {
                print("Failed to fetch users:", error)
                return
            }
            
            //On snapshot object, you will be able to access all the documents
            snapshot?.documents.forEach({ (documentSnapshot) in
                let userDictionary = documentSnapshot.data()
                let user = User(dictionary: userDictionary)
                self.cardViewModels.append(user.toCardViewModel())
                self.lastFetchedUser = user
                self.setupCardFromUser(user: user)
            })
        }
    }
    
    fileprivate func setupCardFromUser(user: User) {
        let cardView = CardView()
        cardView.cardViewModel = user.toCardViewModel()
        cardsDeckView.addSubview(cardView)
        //here we will get to see bit of a flashing when card views are added on deck view
        //hence reduce the z-index of recently added card
        cardsDeckView.sendSubviewToBack(cardView)
        cardView.fillSuperview()
    }
    
    @objc fileprivate func handleRefresh() {
        cardsDeckView.subviews.forEach({ (view) in
            view.layer.removeAllAnimations()
        })
        fetchUsersFromFirestore()
    }

}

