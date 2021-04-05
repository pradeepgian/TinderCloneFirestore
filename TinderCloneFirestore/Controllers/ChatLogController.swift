//
//  ChatLogController.swift
//  TinderCloneFirestore
//
//  Created by Pradeep Gianchandani on 05/04/21.
//

import LBTATools

class ChatLogController: LBTAListController<MessageCell, Message>, UICollectionViewDelegateFlowLayout {
    
    fileprivate lazy var customNavBar = ChatViewNavBar(match: match)
    
    fileprivate let navBarHeight: CGFloat = 120
    
    fileprivate let match: Match
    
    init(match: Match) {
        self.match = match
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // scrolling collection view will result in bouncing effect even when there are less number of messages (items)
        collectionView.alwaysBounceVertical = true
        
        items = [
            .init(text: "Hello from the other side.Hello from the other side.Hello from the other side.Hello from the other side.Hello from the other side.Hello from the other side.Hello from the other side.Hello from the other side.Hello from the other side.Hello from the other side.Hello from the other side.Hello from the other side.Hello from the other side.Hello from the other side.Hello from the other side.Hello from the other side.Hello from the other side.Hello from the other side.Hello from the other side.Hello from the other side.Hello from the other side.Hello from the other side.Hello from the other side.Hello from the other side.Hello from the other side.", isFromCurrentLoggedUser: false),
            .init(text: "Hello.", isFromCurrentLoggedUser: true),
            .init(text: "Hello from the other side.", isFromCurrentLoggedUser: false),
            .init(text: "Bla Bla Bla Bla Bla Bla Bla Bla Bla Bla", isFromCurrentLoggedUser: true)
        ]
        
        view.addSubview(customNavBar)
        customNavBar.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, size: .init(width: 0, height: navBarHeight))
        
        collectionView.contentInset.top = navBarHeight
        
        // here right scroll bar is shown incorrect if top edge inset value is not set
        collectionView.verticalScrollIndicatorInsets.top = navBarHeight
            
        customNavBar.backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        
        // if this is not set, while scrolling messages collection view is visible in status bar
        let statusBarCover = UIView(backgroundColor: .white)
        view.addSubview(statusBarCover)
        statusBarCover.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, trailing: view.trailingAnchor)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // Here the cell size is estimated based on the constraints set
        let estimatedSizeCell = MessageCell(frame: .init(x: 0, y: 0, width: view.frame.width, height: 1000))
        estimatedSizeCell.item = self.items[indexPath.item]
        estimatedSizeCell.layoutIfNeeded()
        
        let estimatedSize = estimatedSizeCell.systemLayoutSizeFitting(.init(width: view.frame.width, height: 1000))
        return .init(width: view.frame.width, height: estimatedSize.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 16, left: 0, bottom: 16, right: 0)
    }
    
    @objc fileprivate func handleBack() {
        navigationController?.popViewController(animated: true)
    }
}

struct Message {
    let text: String
    let isFromCurrentLoggedUser: Bool
}

class MessageCell: LBTAListCell<Message> {
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = .clear
        tv.font = .systemFont(ofSize: 20)
        tv.isScrollEnabled = false
        tv.isEditable = false
        return tv
    }()
    
    let bubbleContainer = UIView(backgroundColor: #colorLiteral(red: 0.9146190882, green: 0.914750576, blue: 0.9145902991, alpha: 1))
    
    override var item: Message! {
        didSet {
            textView.text = item.text
            
            // activate or de-activate constraints if the message is sent from logged in user or not
            if item.isFromCurrentLoggedUser {
                anchoredConstraints.trailing?.isActive = true
                anchoredConstraints.leading?.isActive = false
                bubbleContainer.backgroundColor = #colorLiteral(red: 0.3832361698, green: 0.8062211871, blue: 0.9797287583, alpha: 1)
                textView.textColor = .white
            } else {
                anchoredConstraints.trailing?.isActive = false
                anchoredConstraints.leading?.isActive = true
                bubbleContainer.backgroundColor = #colorLiteral(red: 0.9146190882, green: 0.914750576, blue: 0.9145902991, alpha: 1)
                textView.textColor = .black
            }
        }
    }
    
    var anchoredConstraints: AnchoredConstraints!
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(bubbleContainer)
        bubbleContainer.layer.cornerRadius = 12
        
        
        // store the bubble container constraints in local variable
        // set the leading and trailing constraint to 20 points
        // set the maximum width of bubble container to 250
        anchoredConstraints = bubbleContainer.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
        anchoredConstraints.leading?.constant = 20
        anchoredConstraints.trailing?.isActive = false
        anchoredConstraints.trailing?.constant = -20
        
        bubbleContainer.widthAnchor.constraint(lessThanOrEqualToConstant: 250).isActive = true
        
        bubbleContainer.addSubview(textView)
        textView.fillSuperview(padding: .init(top: 4, left: 12, bottom: 4, right: 12))
    }
}
