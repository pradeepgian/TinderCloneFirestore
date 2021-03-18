//
//  CardView.swift
//  TinderCloneFirestore
//
//  Created by Pradeep Gianchandani on 19/11/20.
//

import UIKit
import SDWebImage

protocol CardViewDelegate {
    func didTapMoreInfo(cardViewModel: CardViewModel)
}
class CardView: UIView {

    var delegate: CardViewDelegate?

    // Here we declare the setter so that when we set the cardViewModel object, all the properties on view are set automatically
    // All the styling related code of the views (like labels, images) will be inside viewmodel
    var cardViewModel: CardViewModel! {
        didSet {

            swipingPhotosController.cardViewModel = self.cardViewModel
            
            informationLabel.attributedText = cardViewModel.attributedString
            informationLabel.textAlignment = cardViewModel.textAlignment
        }
    }
    
    fileprivate let swipingPhotosController = SwipingPhotosController(isCardViewMode: true)
    fileprivate let gradientLayer = CAGradientLayer()
    
    
    
    //Here we implement the getter method to create Information Label
    fileprivate let informationLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()

    fileprivate let moreInfobutton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "info_icon").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleMoreInfo), for: .touchUpInside)
        return button
    }()
    
    @objc fileprivate func handleMoreInfo() {
        delegate?.didTapMoreInfo(cardViewModel: self.cardViewModel)
    }
    
    // MARK:- Configurations
    fileprivate let threshold: CGFloat = 100

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
        // Dont setup gradient layer here. Otherwise, gradient layer will appear on information label as well
        // Call setupGradientLayer() in setupLayout() method before information label is added
        // setupGradientLayer()
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        addGestureRecognizer(panGesture)
        // addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        // We will set the gradient layer frame after the view is initialised
        // If we set gradient layer frame in viewdidload(), then frame origin and size will be 0
        // self.frame will be zero since view is not fully initialised
        gradientLayer.frame = self.frame
    }
    
    fileprivate func setupLayout() {
        //To make the card view rounded on edges
        layer.cornerRadius = 10
        clipsToBounds = true
        
        let swipingPhotosView = swipingPhotosController.view!
        addSubview(swipingPhotosView)
        swipingPhotosView.fillSuperview()
        
        // Gradient layer
        setupGradientLayer()
        
        // Add information label and set its position by setting bottom, left and right anchor to 0 with respect to imageview
        // Add padding to information label by setting edge insets to 16 on left, bottom and right
        addSubview(informationLabel)
        informationLabel.anchor(top: nil, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 16, bottom: 16, right: 16))

        // More Info Button
        addSubview(moreInfobutton)
        moreInfobutton.anchor(top: nil, leading: nil, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 0, bottom: 16, right: 16), size: .init(width: 44, height: 44))
    }
    
    fileprivate func setupGradientLayer() {
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        // Gradient Layer starts from center of screen i.e. 0.5 and ends at 1.1
        gradientLayer.locations = [0.5, 1.1]
        layer.addSublayer(gradientLayer)
    }
    
    @objc fileprivate func handlePan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            // here we remove animation of all the subviews on home view to fix the issue where removed card appears on screen again
            superview?.subviews.forEach({ (subview) in
                subview.layer.removeAllAnimations()
            })
        case .changed:
            handleChanged(gesture)
        case .ended:
            handleEnded(gesture)
        default:
            ()
        }
    }
    
    fileprivate func handleChanged(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: nil)
        
        // Rotation
        
        //Here we divide by 20 to slow the rotation
        let degrees: CGFloat = translation.x / 20
        
        //convert translation.x from degrees to radians
        let angle = degrees * .pi / 180
        
        //create CGAffineTransform object by passing rotation angle to it
        let rotationalTransformation = CGAffineTransform(rotationAngle: angle)
        
        //change the position of card with pan gesture along with rotation angle
        self.transform = rotationalTransformation.translatedBy(x: translation.x, y: translation.y)
    }
    
    fileprivate func handleEnded(_ gesture: UIPanGestureRecognizer) {
        //If gesture.translation is > 0, it means user has swiped in right direction, hence we set translation direction to 1. In case of left swipe, we set it to -1
        let translationDirection: CGFloat = gesture.translation(in: nil).x > 0 ? 1 : -1
        
        //If translation value is greater than threshold, set dismiss card to true
        let shouldDismissCard = abs(gesture.translation(in: nil).x) > threshold
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
            if shouldDismissCard {
                //change the center x position of card to dismiss it
                self.center = CGPoint(x: 600 * translationDirection, y: 0)
            } else {
                //Identity means moving the card to its original (initial) position
                self.transform = .identity
            }
        }) { (_) in
            self.transform = .identity
            if shouldDismissCard {
                //dismiss the card entirely when card
                self.removeFromSuperview()
            }
        }
    }
    
}
