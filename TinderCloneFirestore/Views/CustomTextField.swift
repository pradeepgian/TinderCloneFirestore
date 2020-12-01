//
//  CustomTextField.swift
//  TinderCloneFirestore
//
//  Created by Pradeep Gianchandani on 30/11/20.
//

import UIKit

class CustomTextField: UITextField {
    
    let padding: CGFloat
    
    // We pass the padding parameter to constructor to keep it dynamic
    // Corner Radius and Background color will be static for all the text fields
    init(padding: CGFloat) {
        self.padding = padding
        super.init(frame: .zero)
        layer.cornerRadius = 25
        backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return .init(width: 0, height: 50)
    }
    
    //Returns a drawing rect for text field
    //Here we add padding on left and right side of text
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: padding, dy: 0)
    }
    
    //Returns the rectangle in which editable text can be displayed
    //Here we add padding on left and right side of text
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: padding, dy: 0)
    }
}
