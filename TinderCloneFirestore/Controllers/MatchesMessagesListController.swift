//
//  MessagesController.swift
//  TinderCloneFirestore
//
//  Created by Pradeep Gianchandani on 04/04/21.
//

import LBTATools
import Firebase
//import SDWebImage

class MatchesMessagesListController: LBTAListHeaderController<RecentMessageCell, RecentMessage, MatchesHeader>, UICollectionViewDelegateFlowLayout {
    
    // Create an empty recent messages dictionary
    // key will be udid of user who has sent message
    // value will be recent message sent by user
    var recentMessagesDictionary = [String: RecentMessage]()
    
    var listener: ListenerRegistration?
    
    let customNavBar = MatchesMessagesViewNavBar()
    
    fileprivate let navBarHeight: CGFloat = 150
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchRecentMessages()
        
        setupUI()
    }
    
    // Remove the listener whenever this view is dismissed otherwise it is resulting in retain cycle
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isMovingFromParent {
            listener?.remove()
        }
    }
    
    deinit {
        print("Object is destroying itself properly, no retain cycles or any other memory related issues. Memory being reclaimed properly")
    }
    
    fileprivate func fetchRecentMessages() {
        guard let  currentUserId = Auth.auth().currentUser?.uid else { return }
        
        // Add a snapshot listener to check if new recent messages have been added to the document
        let query = Firestore.firestore().collection("matches_messages").document(currentUserId).collection("recent_messages")
        listener = query.addSnapshotListener { (querySnapshot, error) in
            
            if let error = error {
                print("Error while listening for recent messages:", error)
                return
            }
            
            // change type will be added when new user will send the message
            querySnapshot?.documentChanges.forEach({ (change) in
                if change.type == .added || change.type == .modified {
                    let dictionary = change.document.data()
                    let recentMessage = RecentMessage(dictionary: dictionary)
                    self.recentMessagesDictionary[recentMessage.uid] = recentMessage
                }
            })
            
            self.resetItems()
        }
    }
    
    fileprivate func resetItems() {
        // sort the dictionary values (messages) in descending order
        // so that user who sent the recent message will always be shown at the top
        let values = Array(recentMessagesDictionary.values)
        items = values.sorted(by: { (rm1, rm2) -> Bool in
            return rm1.timestamp.compare(rm2.timestamp) == .orderedDescending
        })
        collectionView.reloadData()
    }
    
    fileprivate func setupUI() {
        collectionView.backgroundColor = .white
        
        customNavBar.backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        
        view.addSubview(customNavBar)
        customNavBar.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, size: .init(width: 0, height: navBarHeight))
        
        // set 150 points spacing from the top so that cells dont hide behind custom nav bar
        collectionView.contentInset.top = navBarHeight
        
        if #available(iOS 13.0, *) {
            collectionView.verticalScrollIndicatorInsets.top = navBarHeight
        } else {
            collectionView.scrollIndicatorInsets.top = navBarHeight
        }
        
        let statusBarCover = UIView(backgroundColor: .white)
        view.addSubview(statusBarCover)
        statusBarCover.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, trailing: view.trailingAnchor)
    }
    
    @objc fileprivate func handleBack() {
        navigationController?.popViewController(animated: true)
    }
    
    //MARK:- Header
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .init(width: view.frame.width, height: 250)
    }
    
    override func setupHeader(_ header: MatchesHeader) {
        header.matchesHorizontalController.rootMatchesController = self
    }
    
    func didSelectMatchFromHeader(match: Match) {
        let chatLogController = ChatLogController(match: match)
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    //MARK:- Cells
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: view.frame.width, height: 130)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 0, left: 0, bottom: 16, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let recentMessage = self.items[indexPath.item]
        let dictionary = ["name": recentMessage.name, "profileImageUrl": recentMessage.profileImageUrl, "uid": recentMessage.uid]
        let match = Match(dictionary: dictionary)
        let controller = ChatLogController(match: match)
        navigationController?.pushViewController(controller, animated: true)
    }
}

class RecentMessageCell: LBTAListCell<RecentMessage> {
    
    let userProfileImageView = UIImageView(image: #imageLiteral(resourceName: "top_left_profile"), contentMode: .scaleAspectFill)
    let usernameLabel = UILabel(text: "USERNAME HERE", font: .boldSystemFont(ofSize: 18))
    let messageTextLabel = UILabel(text: "Some long line of text that should span 2 line", font: .systemFont(ofSize: 16), textColor: .gray, numberOfLines: 2)
    
    override var item: RecentMessage! {
        didSet {
            usernameLabel.text = item.name
            messageTextLabel.text = item.text
            userProfileImageView.sd_setImage(with: URL(string: item.profileImageUrl))
        }
    }
    
    override func setupViews() {
        super.setupViews()
        
        userProfileImageView.layer.cornerRadius = 94 / 2
        
        hstack(userProfileImageView.withWidth(94).withHeight(94),
               stack(usernameLabel, messageTextLabel, spacing: 2),
            spacing: 20, alignment: .center).padLeft(20).padRight(20)
        
        addSeparatorView(leadingAnchor: usernameLabel.leadingAnchor)
    }
}

struct RecentMessage {
    let text, uid, name, profileImageUrl: String
    let timestamp: Timestamp
    
    init(dictionary: [String: Any]) {
        self.text = dictionary["text"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
        self.name = dictionary["name"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
    }
}
