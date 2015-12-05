//
//  NSLayoutConstraint-Extensions.swift
//  My2020
//
//  Created by David Solberg on 10/21/15.
//  Copyright © 2015 David Solberg. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func constraintPresentWidth() -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: self.frame.width)
    }
    
    func constraintPresentHeight() -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: self.frame.height)
    }
    
    func constraintCenterX(inside container : UIView, constant : CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self, attribute: .CenterX, relatedBy: .Equal, toItem: container, attribute: .CenterX, multiplier: 1.0, constant: constant)
    }
    
    func constraintCenterY(inside container : UIView, constant : CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self, attribute: .CenterY, relatedBy: .Equal, toItem: container, attribute: .CenterY, multiplier: 1.0, constant: constant)
    }
    
    func constraintAlignTop(inside container : UIView, constant : CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Top, relatedBy: .Equal, toItem: container, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: constant)
    }
    
    func constraintAlignBottom(inside container : UIView, constant : CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: container, attribute: NSLayoutAttribute.Bottom, relatedBy: .Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: constant)
    }
    
    func constraintAlignLeft(inside container : UIView, constant : CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Left, relatedBy: .Equal, toItem: container, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: constant)
    }
    
    func constraintAlignRight(inside container : UIView, constant : CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: container, attribute: NSLayoutAttribute.Right, relatedBy: .Equal, toItem: self, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: constant)
    }
    
    func constraintsToBox(inside container : UIView, withMarginsAllSides margins : CGFloat) -> [NSLayoutConstraint] {
        let top = constraintAlignTop(inside: container, constant: margins)
        let bottom = constraintAlignBottom(inside: container, constant: margins)
        let left = constraintAlignLeft(inside: container, constant: margins)
        let right = constraintAlignRight(inside: container, constant: margins)
        return [top, bottom, left, right]
    }
}
