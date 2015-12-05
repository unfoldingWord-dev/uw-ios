//
//  DialogBackgroundView.swift
//
//  Copyright © 2015 David Solberg. All rights reserved.
//

import UIKit

typealias CompletionDialogAnimateIn = () -> ()

/// This class is used to show custom dialog boxes or fake actions. It takes care of fading the screen and animating the dialog/actions in and out. Use in conjunction with the extension to NSObject methods: showActionSheetFake, showDialog, and animateOutDialog
class DialogBackgroundView: UIView {
    
    var viewBackground : UIView!
    var viewDialog : UIView!
    let colorTransparentBackground = UIColor(colorLiteralRed: 0.0, green: 0.0, blue: 0.0, alpha: 0.75)
    var constraintCenterY : NSLayoutConstraint?
    var constraintBottomY : NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func setup() {
        addViewBackground()
        self.backgroundColor = UIColor.clearColor()
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func addViewBackground() {
        viewBackground = UIView(frame: self.bounds)
        viewBackground.translatesAutoresizingMaskIntoConstraints = false
        viewBackground.backgroundColor = colorTransparentBackground
        viewBackground.layer.opacity = 0.0
        self.addSubview(viewBackground)
        self.addConstraints(viewBackground.constraintsToBox(inside: self, withMarginsAllSides: 0))
        viewBackground.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "userTappedBackground"))
    }
    
    func animateInActionSheetStyle(dialog : UIView, completion : () -> ())
    {
        dialog.translatesAutoresizingMaskIntoConstraints = false
                
        // Handle on this constraint so we can animate it.
        let leftConst = dialog.constraintAlignLeft(inside: self, constant: 12)
        let rightConst = dialog.constraintAlignRight(inside: self, constant: 12)
        let heightConstraint = dialog.constraintPresentHeight()
        let bottomConstraint = dialog.constraintAlignBottom(inside: self, constant: -dialog.frame.height - 40)
        constraintBottomY = bottomConstraint
        self.addSubview(dialog)
        self.addConstraints([bottomConstraint, leftConst, heightConstraint, rightConst])
        
        self.layoutIfNeeded()
        
        UIView.animateWithDuration(0.4, delay: 0.001, usingSpringWithDamping: 0.85, initialSpringVelocity: 1.2, options: UIViewAnimationOptions.CurveEaseInOut, animations: { [weak self] () -> Void in
            guard let strong = self else { return }
            strong.viewBackground.layer.opacity = 1.0
            bottomConstraint.constant = 12
            strong.updateConstraints()
            strong.layoutIfNeeded()
            }) { (complete : Bool) -> Void in
                completion()
        }
    }
    
    func animateInDialogView(dialog : UIView, completion : () -> ())
    {
        dialog.translatesAutoresizingMaskIntoConstraints = false
        
        let offset = (self.frame.height / 2.0) + (dialog.frame.height / 2.0)
        
        // Handle on this constraint so we can animate it.
        let centerYConstraint = dialog.constraintCenterY(inside: self, constant: -offset)
        let centerXConstraint = dialog.constraintCenterX(inside: self, constant: 0)
        let heightConstraint = dialog.constraintPresentHeight()
        let widthConstraint = dialog.constraintPresentWidth()
        constraintCenterY = centerYConstraint
        self.addSubview(dialog)
        self.addConstraints([centerYConstraint, centerXConstraint, heightConstraint, widthConstraint])
        
        self.layoutIfNeeded()
        
        UIView.animateWithDuration(0.4, delay: 0.001, usingSpringWithDamping: 0.85, initialSpringVelocity: 1.2, options: UIViewAnimationOptions.CurveEaseInOut, animations: { [weak self] () -> Void in
            guard let strong = self else { return }
                strong.viewBackground.layer.opacity = 1.0
                centerYConstraint.constant = 0
                strong.updateConstraints()
                strong.layoutIfNeeded()
            }) { (complete : Bool) -> Void in
                completion()
        }
    }
    
    func userTappedBackground() {
        animateOutDialog() // not the same as the method in this class!!!
    }
    
    func animateOutDialog(completion : () -> Void ) {
        UIView.animateWithDuration(0.4, delay: 0.001, usingSpringWithDamping: 0.85, initialSpringVelocity: 1.2, options: UIViewAnimationOptions.CurveEaseInOut, animations: { [weak self] () -> Void in
            guard let strong = self else { return }
            strong.viewBackground.layer.opacity = 0.0
            if let centerY = strong.constraintCenterY {
                centerY.constant = strong.frame.height
            } else if let bottom = strong.constraintBottomY {
                bottom.constant = -strong.viewBackground.frame.height
            }
            
            strong.updateConstraints()
            strong.layoutIfNeeded()
            }) { (complete : Bool) -> Void in
                completion()
        }
    }
    

}
