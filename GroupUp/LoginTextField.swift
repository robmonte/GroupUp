//
//  LoginTextField.swift
//  GroupUp
//
//  Created by Robert Montefusco on 3/18/17.
//  Copyright © 2017 GroupUp. All rights reserved.
//

import UIKit

class LoginTextField: UITextField {
    
    let padding = UIEdgeInsets(top:0, left:5, bottom:0, right:5)
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func draw(_ rect: CGRect) {
        let startingPoint = CGPoint(x:rect.minX, y:rect.maxY)
        let endingPoint = CGPoint(x:rect.maxX, y:rect.maxY)
        let path = UIBezierPath()
        
        path.move(to:startingPoint)
        path.addLine(to:endingPoint)
        path.lineWidth = 2.0
        
        UIColor.lightGray.setStroke()
        
        path.stroke()
    }
}
