//
//  CardView.swift
//  TinderCloneFirestore
//
//  Created by Pradeep Gianchandani on 19/11/20.
//

import UIKit
import SDWebImage

class CardView: UIView {

    // Here we declare the setter so that when we set the cardViewModel object, all the properties on view are set automatically
    // All the styling related code of the views (like labels, images) will be inside viewmodel
    var cardViewModel: CardViewModel! {
        didSet {
            //Show the first element present in image names array
            //This method is called when home screen loads for first time
            //Accessing index 0 will crash if imageNames.count == 0
            let imageName = cardViewModel.imageNames.first ?? ""
            
            if let url = URL(string: imageName) {
                imageView.sd_setImage(with: url)
            }
            informationLabel.attributedText = cardViewModel.attributedString
            informationLabel.textAlignment = cardViewModel.textAlignment

            //add bars - UIView() on barStackView based on the number of images present in an array
            (0..<cardViewModel.imageNames.count).forEach { (_) in
                let barView = UIView()
                barView.backgroundColor = barDeselectedColor
                barsStackView.addArrangedSubview(barView)
            }
            
            barsStackView.arrangedSubviews.first?.backgroundColor = .white
            
            setupImageIndexObserver()
        }
    }
    
    // MARK:- Encapsulation

    fileprivate func setupImageIndexObserver() {
        cardViewModel.imageIndexObserver = { [weak self] (index, imageUrl) in
            if let url = URL(string: imageUrl ?? "") {
                self?.imageView.sd_setImage(with: url)
            }
            
            self?.barsStackView.arrangedSubviews.forEach { (v) in
                v.backgroundColor = self?.barDeselectedColor
            }
            self?.barsStackView.arrangedSubviews[index].backgroundColor = .white
        }
    }
    
    fileprivate let barDeselectedColor = UIColor(white: 0, alpha: 0.1)
    fileprivate let barsStackView = UIStackView()
    fileprivate let imageView = UIImageView(image: #imageLiteral(resourceName: "pc1"))
    fileprivate let gradientLayer = CAGradientLayer()
    
    
    
    //Here we implement the getter method to create Information Label
    fileprivate let informationLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    
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
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
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
        
        imageView.contentMode = .scaleAspectFill
        addSubview(imageView)
        
        //Entire Card View will be filled with image
        imageView.fillSuperview()
        
        //We set up barstackview after the image is added
        //Barstackview is at higher z-index. Hence, it is visible
        setupBarsStackView()
        setupGradientLayer()
        
        // Add information label and set its position by setting bottom, left and right anchor to 0 with respect to imageview
        // Add padding to information label by setting edge insets to 16 on left, bottom and right
        addSubview(informationLabel)
        informationLabel.anchor(top: nil, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 16, bottom: 16, right: 16))
    }

    fileprivate func setupBarsStackView() {
        barsStackView.spacing = 4
        barsStackView.distribution = .fillEqually
        
        addSubview(barsStackView)
        barsStackView.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 8, left: 8, bottom: 0, right: 8), size: .init(width: 0, height: 4))
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
//            self.frame = CGRect(x: 0, y: 0, width: self.superview!.frame.width, height: self.superview!.frame.height)
        }
    }
    
    @objc fileprivate func handleTap(gesture: UITapGestureRecognizer) {
        let tapLocation = gesture.location(in: nil)
        let shouldAdvanceNextPhoto = tapLocation.x > frame.width / 2 ? true : false
        
        if shouldAdvanceNextPhoto {
            cardViewModel.advanceToNextPhoto()
        } else {
            cardViewModel.goToPreviousPhoto()
        }
    }
}
