//
//  ViewController.swift
//  TinderCloneFirestore
//
//  Created by Pradeep Gianchandani on 19/11/20.
//

import UIKit
import Firebase
import JGProgressHUD

class HomeController: UIViewController, SettingsControllerDelegate, LoginControllerDelegate {
    
    // var cardViewModels = [CardViewModel]()

    fileprivate var user: User?
    fileprivate let hud = JGProgressHUD(style: .dark)
    let topStackView = TopNavigationStackView()
    let cardsDeckView = UIView()
    let bottomControlsStackView = HomeBottomControlsStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        topStackView.settingsButton.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)
        bottomControlsStackView.refreshButton.addTarget(self, action: #selector(handleRefresh), for: .touchUpInside)
        
        setupLayout()
        fetchCurrentUser()
//        setupFirestoreUserCards()
//        fetchUsersFromFirestore()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // When the user logs out on settings controller,
        //
        // present the login controller
        if Auth.auth().currentUser == nil {
            let loginController = LoginController()
            loginController.delegate = self
            let navController = UINavigationController(rootViewController: loginController)
            navController.modalPresentationStyle = .fullScreen
            present(navController, animated: true)
        }
    }
    
    //MARK:- Login Delegate functions
    func didFinishLoggingIn() {
        fetchCurrentUser()
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
    
//    fileprivate func setupFirestoreUserCards() {
//        cardViewModels.forEach { (cardViewModel) in
//            let cardView = CardView()
//            cardView.cardViewModel = cardViewModel
//            
//            cardsDeckView.addSubview(cardView)
//            cardView.fillSuperview()
//        }
//    }
    
    @objc func handleSettings() {
        let settingsController = SettingsController()
        settingsController.delegate = self
        let navController = UINavigationController(rootViewController: settingsController)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
    func didSaveSettings() {
        fetchCurrentUser()
    }

    //MARK:- Firebase
    fileprivate func fetchCurrentUser() {
        self.hud.textLabel.text = "Loading"
        self.hud.show(in: view)
        cardsDeckView.subviews.forEach({$0.removeFromSuperview()})
        Firestore.firestore().fetchCurrentUser { (user, error) in
            self.hud.dismiss()
            if let error = error {
                print("Failed to fetch current user:", error)
                return
            }
            self.user = user
            self.fetchUsersFromFirestore()
        }
    }
    
    var lastFetchedUser: User?
    
    fileprivate func fetchUsersFromFirestore() {
        
        // This query will call the collection of user and you will get documents
        // Firestore provides a query functionality for specifying which documents you want to retrieve from a collection or collection group
        // Check below link for more details
        // https://firebase.google.com/docs/firestore/query-data/queries
        //This query introduces pagination to page through 2 users at a time
        //Here we set the last fetched user while fetching all documents
        //lastFetchedUser is passed while hitting pagination query
        // let query = Firestore.firestore().collection("users").order(by: "uid").start(after: [lastFetchedUser?.uid ?? ""]).limit(to: 2)
        
        guard let minAge = user?.minSeekingAge, let maxAge = user?.maxSeekingAge else { return }
        
        let query = Firestore.firestore().collection("users").whereField("age", isGreaterThanOrEqualTo: minAge).whereField("age", isLessThanOrEqualTo: maxAge)
        query.getDocuments { (snapshot, error) in
            self.hud.dismiss()
            
            if let error = error {
                print("Failed to fetch users:", error)
                return
            }
            
            //On snapshot object, you will be able to access all the documents
            snapshot?.documents.forEach({ (documentSnapshot) in
                let userDictionary = documentSnapshot.data()
                let user = User(dictionary: userDictionary)
//                self.cardViewModels.append(user.toCardViewModel())
//                self.lastFetchedUser = user
                //If not a current user, then add user card to stack
                if user.uid != Auth.auth().currentUser?.uid {
                    self.setupCardFromUser(user: user)
                }
            })
        }
    }
    
    fileprivate func setupCardFromUser(user: User) {
        let cardView = CardView()
//        cardView.delegate = self
        cardView.cardViewModel = user.toCardViewModel()
        cardsDeckView.addSubview(cardView)
        //here we will get to see bit of a flashing when card views are added on deck view
        //hence reduce the z-index of recently added card
        cardsDeckView.sendSubviewToBack(cardView)
        cardView.fillSuperview()
    }
    

    func didTapMoreInfo() {
        // let userDetailsController = UserDetailsController()
        // userDetailsController.modalPresentationStyle = .fullScreen
        // present(userDetailsController, animated: true)
    }
    @objc fileprivate func handleRefresh() {
        cardsDeckView.subviews.forEach({ (view) in
            view.layer.removeAllAnimations()
        })
        fetchUsersFromFirestore()
    }

}

