//
//  ViewController.swift
//  TinderCloneFirestore
//
//  Created by Pradeep Gianchandani on 19/11/20.
//

import UIKit
import Firebase
import JGProgressHUD

class HomeController: UIViewController, SettingsControllerDelegate, LoginControllerDelegate, CardViewDelegate {
    
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
        bottomControlsStackView.likeButton.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        bottomControlsStackView.dislikeButton.addTarget(self, action: #selector(handleDislike), for: .touchUpInside)
        setupLayout()
        fetchCurrentUser()
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
            
            if let error = error {
                print("Failed to fetch current user:", error)
                self.hud.dismiss()
                return
            }
            self.user = user
            self.fetchSwipes()
        }
    }
    
    var swipes = [String: Int]()
    
    fileprivate func fetchSwipes() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("swipes").document(uid).getDocument { (snapshot, error) in
            if let error = error {
                print("Failed to fetch swipes info for currently logged in user:", error)
                return
            }
            
            print("Swipes:", snapshot?.data() ?? "")
//            guard let data = snapshot?.data() as? [String: Int] else { return }
//            self.swipes = data
            if let data = snapshot?.data() as? [String: Int] {
                self.swipes = data
            }
            self.fetchUsersFromFirestore()
        }
    }
    
    var lastFetchedUser: User?
    
    fileprivate func fetchUsersFromFirestore() {
        
        
        cardsDeckView.subviews.forEach({$0.removeFromSuperview()})
        
        //set it to nil everytime when we fetch the users from firestore
        topCardView = nil
        
        // This query will call the collection of user and you will get documents
        // Firestore provides a query functionality for specifying which documents you want to retrieve from a collection or collection group
        // Check below link for more details
        // https://firebase.google.com/docs/firestore/query-data/queries
        //This query introduces pagination to page through 2 users at a time
        //Here we set the last fetched user while fetching all documents
        //lastFetchedUser is passed while hitting pagination query
        // let query = Firestore.firestore().collection("users").order(by: "uid").start(after: [lastFetchedUser?.uid ?? ""]).limit(to: 2)
        
        // guard let minAge = user?.minSeekingAge, let maxAge = user?.maxSeekingAge else { return }
        //Here we will provide default min and max seeking age otherwise loading indicator is shown for infinite duration
        let minAge = user?.minSeekingAge ?? SettingsController.defaultMinSeekingAge
        let maxAge = user?.maxSeekingAge ?? SettingsController.defaultMaxSeekingAge
        let query = Firestore.firestore().collection("users").whereField("age", isGreaterThanOrEqualTo: minAge).whereField("age", isLessThanOrEqualTo: maxAge)
        query.getDocuments { (snapshot, error) in
            self.hud.dismiss()
            
            if let error = error {
                print("Failed to fetch users:", error)
                return
            }
            
            // Linked List
            var previousCardView: CardView?
            
            //On snapshot object, you will be able to access all the documents
            snapshot?.documents.forEach({ (documentSnapshot) in
                let userDictionary = documentSnapshot.data()
                let user = User(dictionary: userDictionary)
                //If not a current user, then add user card to stack
                let isNotCurrentUser = user.uid != Auth.auth().currentUser?.uid
                let hasNotSwippedBefore = self.swipes[user.uid!] == nil
                
                if isNotCurrentUser && hasNotSwippedBefore  {
                    let cardView = self.setupCardFromUser(user: user)
                    //Lets say first card is Jane
                    //second card is pradeep
                    //third card is deepak
                    
                    // in 1st iteration, previousCardView will be nil and will be set to jane
                    // In 2nd iteration, previousCardView?.nextCardView will be pradeep and previousCardView object will become pradeep
                    // and so on..
                    // In short, we keep on setting nextCardView property for each card
                    previousCardView?.nextCardView = cardView
                    previousCardView = cardView
                    
                    // in all iterations, topCardView will be jane
                    if self.topCardView == nil {
                        self.topCardView = cardView
                    }
                }
            })
        }
    }
    
    fileprivate func setupCardFromUser(user: User) -> CardView {
        let cardView = CardView()
        cardView.delegate = self
        cardView.cardViewModel = user.toCardViewModel()
        cardsDeckView.addSubview(cardView)
        //here we will get to see bit of a flashing when card views are added on deck view
        //hence reduce the z-index of recently added card
        cardsDeckView.sendSubviewToBack(cardView)
        cardView.fillSuperview()
        return cardView
    }
    
    func didTapMoreInfo(cardViewModel: CardViewModel) {
        print("Home controller:", cardViewModel.attributedString)
        let userDetailsController = UserDetailsController()
        userDetailsController.cardViewModel = cardViewModel
        userDetailsController.modalPresentationStyle = .fullScreen
        present(userDetailsController, animated: true)
    }
    
    @objc fileprivate func handleRefresh() {
        cardsDeckView.subviews.forEach({ (view) in
            view.layer.removeAllAnimations()
        })
        fetchUsersFromFirestore()
    }
    
    var topCardView: CardView?
    
    @objc func handleLike() {
        saveSwipeToFirestore(didLike: 1)
        performSwipeAnimation(translation: 700, angle: 15)
    }
    
    @objc func handleDislike() {
        saveSwipeToFirestore(didLike: 0)
        performSwipeAnimation(translation: -700, angle: -15)
    }
    
    fileprivate func saveSwipeToFirestore(didLike: Int) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        guard let cardUID = topCardView?.cardViewModel.uid else { return }
        let documentData = [cardUID: didLike]
        
        Firestore.firestore().collection("swipes").document(uid).getDocument { (snapshot, error) in
            if let error = error {
                print("Failed to fetch swipe document:", error)
                return
            }
            
            if snapshot?.exists == true {
                Firestore.firestore().collection("swipes").document(uid).updateData(documentData) { (error) in
                    if let error = error {
                        print("Failed to save swipe data:", error)
                        return
                    }
                    print("Successfully updated swipe")
                    self.checkIfMatchExists(cardUID: cardUID)
                }
            } else {
                Firestore.firestore().collection("swipes").document(uid).setData(documentData) { (error) in
                    if let error = error {
                        print("Failed to save swipe data:", error)
                        return
                    }
                    print("Successfully saved swipe")
                    self.checkIfMatchExists(cardUID: cardUID)
                }
            }
        }
    }
    
    fileprivate func checkIfMatchExists(cardUID: String) {
        print("Detecting match")
        
        Firestore.firestore().collection("swipes").document(cardUID).getDocument { (snapshot, error) in
            if let error = error {
                print("Failed to fetch document for card user:", error)
                return
            }
            
            guard let data = snapshot?.data() else { return }
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            let hasMatched = data[uid] as? Int == 1
            if hasMatched {
                print("Has matched")
                let hud = JGProgressHUD(style: .dark)
                hud.textLabel.text = "Found a match"
                hud.show(in: self.view)
                
                hud.dismiss(afterDelay: 4, animated: true)
            }
        }
    }
    
    fileprivate func performSwipeAnimation(translation: CGFloat, angle: CGFloat) {
        let duration = 0.5
        
        let translationAnimation = CABasicAnimation(keyPath: "position.x")
        translationAnimation.toValue = translation
        translationAnimation.duration = duration
        translationAnimation.fillMode = .forwards
        translationAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        translationAnimation.isRemovedOnCompletion = false
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = angle * CGFloat.pi / 180
        rotationAnimation.duration = duration
        
        let cardView = topCardView
        topCardView = cardView?.nextCardView
        
        CATransaction.setCompletionBlock {
            cardView?.removeFromSuperview()
        }
        
        cardView?.layer.add(translationAnimation, forKey: "translation")
        cardView?.layer.add(rotationAnimation, forKey: "rotation")
        
        CATransaction.commit()
    }
    
    func didRemoveCard(cardView: CardView) {
        topCardView?.removeFromSuperview()
        topCardView = self.topCardView?.nextCardView
    }

}

