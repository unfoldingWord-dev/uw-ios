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

    @IBOutlet weak var labelButtonLanguage: ACTLabelButton! {
        didSet {
            labelButtonLanguage.delegate = self
            labelButtonLanguage.font = FONT_LIGHT()
            labelButtonLanguage.colorHover = UIColor.lightGrayColor()
        }
    }
    
    private var arrayVersionChooserViews: [VersionChooserView]?
    
    var expanded : Bool! {
        didSet {
            sharingInfo.isExpanded = expanded
            updateCellViews()
        }
    }

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
        addVersionChooserViews()
    }

    private func addVersionChooserViews()
    {
        arrayVersionChooserViews = sharingInfo.arrayVersionSharingInfo.map { VersionChooserView.createWithInfo($0) }
        
        guard let views = arrayVersionChooserViews where views.count > 0 else {
            assertionFailure("NO available views for info \(sharingInfo)")
            return
        }
        
        var previousView : UIView = labelButtonLanguage
        
        views.forEach { (view) -> () in
            addConstraints( NSLayoutConstraint.constraintsToPutView(view, belowView: previousView, padding: 0, withContainerView: self, leftMargin: 16, rightMargin: 16)! )
            addSubview(view)
            previousView = view
        }
        
        addConstraint( NSLayoutConstraint(item: self, attribute: .Bottom, relatedBy: .Equal, toItem: previousView, attribute: .Bottom, multiplier: 1, constant: 0))
    }


    func updateLanguageCell() {
        labelButtonLanguage.text = LanguageInfoController.nameForLanguageCode(sharingInfo.language.lc)
        labelButtonLanguage.direction = sharingInfo.isExpanded ? .Down : .Up
    }
    
    private func removeExistingChooserViews() {
        guard let chooserViews = arrayVersionChooserViews else { return }
        chooserViews.forEach { $0.removeFromSuperview() }
    }
    
}
