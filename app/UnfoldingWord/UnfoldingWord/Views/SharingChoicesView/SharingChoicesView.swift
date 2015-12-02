//
//  SharingChoicesView.swift
//  UnfoldingWord
//
//  Created by David Solberg on 12/1/15.
//  Copyright © 2015 Acts Media Inc. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

class SharingChoicesView: UIView {
    
    let buttonHeight : CGFloat = 44

    var completionBlock : ShareOptionsBlock!
    var options : DownloadOptions = [DownloadOptions.Text]
    
    static func createWithOptions(options: DownloadOptions, completion : ShareOptionsBlock) -> SharingChoicesView
    {
        let shareView = SharingChoicesView()
        shareView.options = options
        shareView.completionBlock = completion
        shareView.setupAllViews()
        return shareView
    }
    
    private func setupAllViews()
    {
        // Add label
        let topLabel = UILabel(frame: CGRectMake(0,0,1,1))
        topLabel.text = "CHOOSE WHAT TO SHARE..."
        topLabel.translatesAutoresizingMaskIntoConstraints = false
        let labelConst = NSLayoutConstraint.constraintsForView(topLabel, insideView: self, topMargin: 10, leftMargin: 0, rightMargin: 0, height: 30)
        self.addSubview(topLabel)
        self.addConstraints(labelConst!)
        
        // Add choices
        guard let choiceView = createChoiceButtonView(options) else { assertionFailure("Choices Empty!"); return }
        choiceView.translatesAutoresizingMaskIntoConstraints = false
        let choiceConst = NSLayoutConstraint.constraintsToFloatView(choiceView, belowView: topLabel, padding: 4, withContainerView: self, leftMargin: 0, rightMargin: 0)
        self.addSubview(choiceView)
        self.addConstraints(choiceConst)
        
        // Add Share Button
        let shareButton = UIButton(frame: CGRectMake(0,0,1,buttonHeight))
        shareButton.setTitle("Share", forState: .Normal)
        shareButton.titleLabel!.font = UIFont.boldSystemFontOfSize(18)
        shareButton.addTarget(self, action: "userPressedShareButton", forControlEvents: .TouchUpInside)
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        let shareConst = NSLayoutConstraint.constraintsToPutView(shareButton, belowView: choiceView, padding: 4, withContainerView: self, leftMargin: 0, rightMargin: 0)!
        self.addSubview(shareButton)
        self.addConstraints(shareConst)
        
        // Add Cancel Button
        let cancelButton = UIButton(frame: CGRectMake(0,0,1,buttonHeight))
        cancelButton.setTitle("Cancel", forState: .Normal)
        cancelButton.backgroundColor = UIColor.whiteColor()
        cancelButton.layer.cornerRadius = 10
        cancelButton.addTarget(self, action: "userPressedCancelButton", forControlEvents: .TouchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        let cancelConst = NSLayoutConstraint.constraintsToPutView(cancelButton, belowView: choiceView, padding: 4, withContainerView: self, leftMargin: 0, rightMargin: 0)!
        self.addSubview(cancelButton)
        self.addConstraints(cancelConst)
        
        // Add Bottom Defining Constraint
        let bottomConstraint = NSLayoutConstraint(item: cancelButton, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0)
        self.addConstraint(bottomConstraint)
    }
    
    func userPressedShareButton() {
        
        animateOutDialog()

    }
    
    func userPressedCancelButton() {
        
        animateOutDialog()
    }
    
    private func createChoiceButtonView(options : DownloadOptions) -> UIView?
    {
        let buttonBackground = UIView(frame: CGRectMake(0,0,1,buttonHeight))
        buttonBackground.backgroundColor = UIColor.lightGrayColor()
        var previousView : UIView? = nil
        arrayOfChoices(options).forEach { (view) -> () in
            view.translatesAutoresizingMaskIntoConstraints = false
            let constraints : [NSLayoutConstraint]
            if let previousView = previousView {
                constraints = NSLayoutConstraint.constraintsToPutView(view, belowView: previousView, padding: 4, withContainerView: buttonBackground, leftMargin: 0, rightMargin: 0)!
            } else {
                constraints = NSLayoutConstraint.constraintsTopAnchorView(view, insideView: buttonBackground, height: buttonHeight)!
            }
            buttonBackground.addSubview(view)
            buttonBackground.addConstraints(constraints)
            previousView = view
        }
        guard let lastView = previousView else { return nil}
        let bottomConstraint = NSLayoutConstraint(item: lastView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: buttonBackground, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0)
        buttonBackground.addConstraint(bottomConstraint)
        return buttonBackground
    }
    
    private func arrayOfChoices(options : DownloadOptions) -> [CheckChoiceView]
    {
        var choicesArray = [CheckChoiceView]()
        
        let textChoice = CheckChoiceView.createWithType(.Text)
        textChoice.userInteractionEnabled = false
        choicesArray.append(textChoice)
        
        if (options.contains(.Audio)) {
            choicesArray.append(CheckChoiceView.createWithType(.Audio))
        }
        
        if (options.contains(.Video)) {
            choicesArray.append(CheckChoiceView.createWithType(.Video))
        }
        
        return choicesArray
    }
    
}
