//
//  LanguageShareChooserTableCell.swift
//  UnfoldingWord
//
//  Created by David Solberg on 12/10/15.
//  Copyright © 2015 Acts Media Inc. All rights reserved.
//

import UIKit

protocol LanguageChooserCellDelegate {
    func userTappedCell(cell: LanguageShareChooserTableCell)
}

class LanguageShareChooserTableCell: UITableViewCell, ACTLabelButtonDelegate {
    
    var sharingInfo : LanguageSharingInfo! {
        didSet { updateCellViews() }
    }
    
    var delegate : LanguageChooserCellDelegate? = nil
    var constraintLabelBottom : NSLayoutConstraint?

    @IBOutlet weak var labelButtonLanguage: ACTLabelButton! {
        didSet {
            labelButtonLanguage.delegate = self
            labelButtonLanguage.font = FONT_MEDIUM()
            labelButtonLanguage.colorHover = UIColor.lightGrayColor()
        }
    }
    
    private var arrayVersionChooserViews: [VersionChooserView]?

    func labelButtonPressed(labelButton: ACTLabelButton!) {
        guard let delegate = delegate else {
            assertionFailure("The delegate cannot be nil for cell \(self)")
            return
        }
        delegate.userTappedCell(self)
    }
    
    func updateCellViews()
    {
        updateLanguageCell()
        removeExistingChooserViews()
        addVersionChooserViewsIfNecessary()
    }

    private func addVersionChooserViewsIfNecessary()
    {
        if let constraint = constraintLabelBottom {
            self.contentView.removeConstraint(constraint)
            constraintLabelBottom = nil
        }
        
        guard sharingInfo.isExpanded else {
            let bottomConst = NSLayoutConstraint(item: self.contentView, attribute: .Bottom, relatedBy: .Equal, toItem: labelButtonLanguage, attribute: .Bottom, multiplier: 1, constant: 8)
            self.contentView.addConstraint(bottomConst)
            constraintLabelBottom = bottomConst
            return
        }
        
        arrayVersionChooserViews = sharingInfo.arrayVersionSharingInfo.map { VersionChooserView.createWithInfo($0) }
        
        guard let views = arrayVersionChooserViews where views.count > 0 else { return }
        
        var previousView : UIView = labelButtonLanguage
        
        views.forEach { (view) -> () in
            self.contentView.addSubview(view)
            self.contentView.addConstraints( NSLayoutConstraint.constraintsToFloatView(view, belowView: previousView, padding: 6, withContainerView: self.contentView, leftMargin: 12, rightMargin: 16) )
            previousView = view
        }
        
        self.contentView.addConstraint( NSLayoutConstraint(item: self.contentView, attribute: .Bottom, relatedBy: .Equal, toItem: previousView, attribute: .Bottom, multiplier: 1, constant: 12))
    }


    func updateLanguageCell() {
        labelButtonLanguage.text = LanguageInfoController.nameForLanguageCode(sharingInfo.language.lc)
        labelButtonLanguage.direction = sharingInfo.isExpanded ? .Down : .Up
    }
    
    private func removeExistingChooserViews() {
        arrayVersionChooserViews?.forEach { $0.removeFromSuperview() }
    }
    
}
