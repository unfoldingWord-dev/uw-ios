//
//  DialogBackgroundView.swift
//
//  Copyright © 2015 David Solberg. All rights reserved.
//

import UIKit

typealias CompletionDialogAnimateIn = () -> ()

class DialogBackgroundView: UIView {
    
    var viewBackground : UIView!
    var viewDialog : UIView!
    let colorTransparentBackground = UIColor(colorLiteralRed: 0.25, green: 0.25, blue: 0.25, alpha: 0.75)
    var constraintCenterY : NSLayoutConstraint!
    
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
    }
    
    func animateInDialogView(dialog : UIView, completion : () -> ())
    {
        dialog.translatesAutoresizingMaskIntoConstraints = false
        
        let offset = (self.frame.height / 2.0) + (dialog.frame.height / 2.0)
        
        // Handle on this constraint so we can animate it.
        constraintCenterY = dialog.constraintCenterY(inside: self, constant: -offset)
        let centerXConstraint = dialog.constraintCenterX(inside: self, constant: 0)
        let heightConstraint = dialog.constraintPresentHeight()
        let widthConstraint = dialog.constraintPresentWidth()
        
        self.addSubview(dialog)
        self.addConstraints([constraintCenterY, centerXConstraint, heightConstraint, widthConstraint])
        
        self.layoutIfNeeded()
        
        UIView.animateWithDuration(0.4, delay: 0.001, usingSpringWithDamping: 0.85, initialSpringVelocity: 1.2, options: UIViewAnimationOptions.CurveEaseInOut, animations: { [weak self] () -> Void in
            guard let strong = self else { return }
                strong.viewBackground.layer.opacity = 1.0
                strong.constraintCenterY.constant = 0
                strong.updateConstraints()
                strong.layoutIfNeeded()
            }) { (complete : Bool) -> Void in
                completion()
        }
    }
    
    func animateOutDialog(completion : () -> () ) {
        UIView.animateWithDuration(0.4, delay: 0.001, usingSpringWithDamping: 0.85, initialSpringVelocity: 1.2, options: UIViewAnimationOptions.CurveEaseInOut, animations: { [weak self] () -> Void in
            guard let strong = self else { return }
            strong.viewBackground.layer.opacity = 0.0
            strong.constraintCenterY.constant = strong.frame.height
            strong.updateConstraints()
            strong.layoutIfNeeded()
            }) { (complete : Bool) -> Void in
                completion()
        }
    }
    

}
