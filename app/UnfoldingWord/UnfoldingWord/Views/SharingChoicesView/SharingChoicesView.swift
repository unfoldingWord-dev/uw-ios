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
    var choiceViews : [CheckChoiceView]!
    
    static func createWithOptions(options: DownloadOptions, completion : ShareOptionsBlock) -> SharingChoicesView
    {
        let shareView = SharingChoicesView()
        shareView.options = options
        shareView.completionBlock = completion
        shareView.addAllViews()
        return shareView
    }
    
    private func addAllViews()
    {
        let viewGroup1 = UIView(frame: CGRectMake(0,0,1,1))
        viewGroup1.translatesAutoresizingMaskIntoConstraints = false
        viewGroup1.backgroundColor = Constants.Color.lightGray
        viewGroup1.layer.cornerRadius = 8
        
        // Add label
        let topLabel = UILabel(frame: CGRectMake(0,0,1,1))
        topLabel.text = "CHOOSE WHAT TO SHARE..."
        topLabel.textColor = UIColor.darkGrayColor()
        topLabel.translatesAutoresizingMaskIntoConstraints = false
        let labelConst = NSLayoutConstraint.constraintsForView(topLabel, insideView: viewGroup1, topMargin: 16, leftMargin: 12, rightMargin: 12, height: 28)
        viewGroup1.addSubview(topLabel)
        viewGroup1.addConstraints(labelConst!)
        
        // Add choices
        guard let choiceView = createChoiceButtonView(options) else { assertionFailure("Choices Empty!"); return }
        choiceView.translatesAutoresizingMaskIntoConstraints = false
        let choiceConst = NSLayoutConstraint.constraintsToFloatView(choiceView, belowView: topLabel, padding: 4, withContainerView: viewGroup1, leftMargin: 0, rightMargin: 0)
        viewGroup1.addSubview(choiceView)
        viewGroup1.addConstraints(choiceConst)
        
        // Add Share Button
        let shareButton = UIButton(frame: CGRectMake(0,0,1,buttonHeight))
        shareButton.setTitle("Share", forState: .Normal)
        shareButton.setTitleColor(Constants.Color.lightBlue, forState: .Normal)
        shareButton.titleLabel!.font = UIFont.boldSystemFontOfSize(18)
        shareButton.addTarget(self, action: "userPressedShareButton", forControlEvents: .TouchUpInside)
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        shareButton.tintColor = UIColor.blueColor()
        let shareConst = NSLayoutConstraint.constraintsToPutView(shareButton, belowView: choiceView, padding: 4, withContainerView: viewGroup1, leftMargin: 0, rightMargin: 0)!
        viewGroup1.addSubview(shareButton)
        viewGroup1.addConstraints(shareConst)
        
        // Add Bottom Defining Constraint for Top Area (Group 1)
        let group1bottomConstraint = NSLayoutConstraint(item: shareButton, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: viewGroup1, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0)
        viewGroup1.addConstraint(group1bottomConstraint)
        
        let group1Constraints = NSLayoutConstraint.constraintsTopAnchorView(viewGroup1, insideView: self)
        self.addSubview(viewGroup1)
        self.addConstraints(group1Constraints)
        
        // Add Cancel Button
        let cancelButton = UIButton(frame: CGRectMake(0,0,1,buttonHeight))
        cancelButton.setTitle("Cancel", forState: .Normal)
        cancelButton.setTitleColor(UIColor.redColor(), forState: .Normal)
        cancelButton.backgroundColor = UIColor.whiteColor()
        cancelButton.layer.cornerRadius = 8
        cancelButton.addTarget(self, action: "userPressedCancelButton", forControlEvents: .TouchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        let cancelConst = NSLayoutConstraint.constraintsToPutView(cancelButton, belowView: viewGroup1, padding: 8, withContainerView: self, leftMargin: 0, rightMargin: 0)!
        self.addSubview(cancelButton)
        self.addConstraints(cancelConst)
        
        // Add Bottom Defining Constraint
        let bottomConstraint = NSLayoutConstraint(item: cancelButton, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0)
        self.addConstraint(bottomConstraint)
    }
    
    func userPressedShareButton() {
        completionBlock(canceled: false, shareOptions: selectedOptions)
        animateOutDialog()

    }
    
    func userPressedCancelButton() {
        completionBlock(canceled: true, shareOptions: DownloadOptions.Empty)
        animateOutDialog()
    }
    
    var selectedOptions : DownloadOptions {
        get {
            return choiceViews.reduce(DownloadOptions.Empty) { (optionSet, choiceView) -> DownloadOptions in
                guard choiceView.selected else { return optionSet }
                var set = optionSet
                switch choiceView.type {
                case .Text:
                    set.insert(.Text)
                case .Audio:
                    set.insert(.Audio)
                case .Video:
                    set.insert(.Video)
                case .None:
                    assertionFailure("There should not be a option with no type!")
                }
                return set
            }
        }
    }
    
    private func createChoiceButtonView(options : DownloadOptions) -> UIView?
    {
        let buttonBackground = UIView(frame: CGRectMake(0,0,1,1))
        buttonBackground.backgroundColor = UIColor.clearColor()
        var previousView : UIView? = nil
        choiceViews = arrayOfChoices(options)
        choiceViews.forEach { (view) -> () in
            view.translatesAutoresizingMaskIntoConstraints = false
            view.frame.size.height = buttonHeight
            let constraints : [NSLayoutConstraint]
            if let previousView = previousView {
                constraints = NSLayoutConstraint.constraintsToPutView(view, belowView: previousView, padding: 2, withContainerView: buttonBackground, leftMargin: 0, rightMargin: 0)!
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
