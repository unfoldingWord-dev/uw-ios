//
//  FakeNavBarView.swift
//  UnfoldingWord
//
//  Created by David Solberg on 9/14/15.
//  Copyright © 2015 Acts Media Inc. All rights reserved.
//

import Foundation

enum SideBarState {
    case MainOnly
    case MainPlusSide
}

enum NavButtonType {
    case VersionMain
    case VersionSide
    case BookChapter
}

protocol FakeNavBarDelegate : class {
    func expandToFullSize() -> Void
    func navBackButtonPressed() -> Void
    func navButtonPressed(button : ACTLabelButton, type : NavButtonType) -> Void
}

class FakeNavBarView : UIView, ACTLabelButtonDelegate {
    
    let fontSizeCondensed : CGFloat = 15.0
    let fontSizeFull : CGFloat = 17.0
    let opacityCondensed : CGFloat = 0.7
    
    let minimumHeight : CGFloat = 20
    let maximumHeight : CGFloat = 50
    let minSpaceBetweenVersion : CGFloat = 100
    let titleInset : CGFloat = 40
    let titleBuffer : CGFloat = 60 // ÷ 2 points on either side
    let maxHeightTitleVersionOffset : CGFloat = -20
    
    weak var delegate : FakeNavBarDelegate? = nil
    
    var sideBarState : SideBarState = .MainOnly {
        didSet {
            UIView.animateWithDuration(0.25, delay: 0, options: .CurveEaseInOut, animations: { [weak self] () -> Void in
                guard let sself = self else {return}
                switch sself.sideBarState {
                case .MainOnly:
                    sself.viewSSVersionContainer.layer.opacity = 0.0
                    sself.labelButtonVersionMainAlone.layer.opacity = 1.0
                    sself.constraintDistanceBetweenSSVersions.constant = 0
                case .MainPlusSide:
                    sself.viewSSVersionContainer.layer.opacity = 1.0
                    sself.labelButtonVersionMainAlone.layer.opacity = 0.0
                    sself.constraintDistanceBetweenSSVersions.constant = sself.maxHeightTitleVersionOffset
                }
                sself.setNeedsUpdateConstraints()
                sself.layoutIfNeeded()
                }) { (didComplete) -> Void in }
        }
    }
    
    @IBOutlet weak var buttonBackArrow: UIButton!
    @IBOutlet weak var buttonBackground: UIButton!
    
    @IBOutlet weak var labelButtonBookPlusChapter: ACTLabelButton! {
        didSet {  setUpLabelButton(labelButtonBookPlusChapter) }
    }
    
    @IBOutlet weak var viewSSVersionContainer: UIView!
    
    @IBOutlet weak var labelButtonSSVersionMain: ACTLabelButton! {
        didSet {  setUpLabelButton(labelButtonSSVersionMain)  }
    }
    @IBOutlet weak var labelButtonSSVersionSide: ACTLabelButton! {
        didSet {  setUpLabelButton(labelButtonSSVersionSide)  }
    }
    
    @IBOutlet weak var labelButtonVersionMainAlone: ACTLabelButton! {
        didSet {  setUpLabelButton(labelButtonVersionMainAlone) }
    }
    
    @IBOutlet var constraintDistanceSSContainerFromBook: NSLayoutConstraint!
    @IBOutlet var constraintDistanceBetweenSSVersions: NSLayoutConstraint!
    
    @IBAction func userPressedBackgroundButton(sender: AnyObject) {
        if let delegate = delegate where isAtMinHeight() {
            delegate.expandToFullSize()
        }
        else {
            buttonBackground.enabled = false
        }
    }
    
    @IBAction func userPressedBackButton(sender : UIButton) {
        delegate?.navBackButtonPressed()
    }
    
    func isAtMinHeight() -> Bool {
        return self.frame.height < (minimumHeight + 0.1)
    }
    
    func labelButtonPressed(labelButton: ACTLabelButton!) {
        let buttonType : NavButtonType
        if labelButton.isEqual(labelButtonSSVersionMain) || labelButton.isEqual(labelButtonVersionMainAlone) {
            buttonType = .VersionMain
        }
        else if labelButton.isEqual(labelButtonSSVersionSide) {
            buttonType = .VersionSide
        }
        else if labelButton.isEqual(labelButtonBookPlusChapter) {
            buttonType = .BookChapter
        }
        else {
            assertionFailure("Could not get type of button \(labelButton)")
            return
        }
        
        if let delegate = self.delegate {
            delegate.navButtonPressed(labelButton, type: buttonType)
        }
    }
    
    override func updateConstraints() {
        let fraction = fractionHidden()
        buttonBackArrow.layer.opacity = Float(fraction)
        constraintDistanceBetweenSSVersions.constant = distanceBetweenSSVersionsUsingFraction(fraction)
        // sqrt makes a quadratic curve to help avoid the edges of the title
        if sideBarState == .MainOnly {
            constraintDistanceSSContainerFromBook.constant = 0.0
        }
        else {
            constraintDistanceSSContainerFromBook.constant = pow(fraction, 2) * maxHeightTitleVersionOffset
        }

        super.updateConstraints()
        
        let font = FONT_MEDIUM().fontWithSize(fontSizeForPercentHidden(fraction))
        let opacity = opacityForPercentHidden(fraction)
        for (_, labelButton) in labelButtons().enumerate() {
            labelButton.font = font
            if (labelButton.layer.opacity > 0.1) {
                labelButton.layer.opacity = Float(opacity)
            }
        }
        
        buttonBackground.enabled = isAtMinHeight()
    }
    
    private func labelButtons() -> [ACTLabelButton!] {
        return [labelButtonBookPlusChapter, labelButtonSSVersionMain, labelButtonSSVersionSide, labelButtonVersionMainAlone]
    }
    
    private func fontSizeForPercentHidden(percent : CGFloat) -> CGFloat {
        let difference = fontSizeFull - fontSizeCondensed
        let addon = difference * percent
        return fontSizeCondensed + addon
    }
    
    private func opacityForPercentHidden(percent : CGFloat) -> CGFloat {
        return opacityCondensed + ( (1 - opacityCondensed) * percent )
    }
    
    // Helpers
    
    private func fractionHidden() -> CGFloat {
        let heightDiff = self.frame.height - minimumHeight
        return heightDiff / (maximumHeight - minimumHeight)
    }
    
    private func distanceBetweenSSVersionsUsingFraction(fractionAboveMinHeight : CGFloat) -> CGFloat {
        let titleWidth = labelButtonBookPlusChapter.intrinsicContentSize().width
        let distanceAtMinHeight = titleWidth + titleBuffer
        let distanceAtMaxHeight = fmax(titleWidth - titleInset, minSpaceBetweenVersion)
        let distanceDiff = fmax(0, distanceAtMinHeight-distanceAtMaxHeight)
        let addOnDifference = distanceDiff * (1-fractionAboveMinHeight)
        return distanceAtMaxHeight + addOnDifference
    }
    
    private func setUpLabelButton(button : ACTLabelButton) {
        button.isHidingArrow = true
        button.delegate = self
        button.colorHover = UIColor(red: 0.6, green: 0.87, blue: 0.81, alpha: 1.0)
        button.colorNormal = UIColor.whiteColor()
        button.font = FONT_MEDIUM().fontWithSize(15)
    }
}

