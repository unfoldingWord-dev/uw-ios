//
//  VersionChooserView.swift
//  UnfoldingWord
//
//  Created by David Solberg on 12/11/15.
//  Copyright © 2015 Acts Media Inc. All rights reserved.
//

import UIKit

enum CheckState {
    case None
    case Partial
    case Complete
}

class VersionChooserView: UIView {

    @IBOutlet weak var buttonCheckmark: UIButton!
    @IBOutlet weak var labelVersionName: UILabel!
    
    private var sharingInfo : VersionSharingInfo! {
        didSet {  updateCellsBasedOnSharingInfo() }
    }
    
    private var state = CheckState.None {
        didSet {
            switch state {
            case .None:
                buttonCheckmark.setBackgroundImage(UIImage(named: Constants.ImageName.checklessBox), forState: .Normal)
            case .Partial:
                buttonCheckmark.setBackgroundImage(UIImage(named: Constants.ImageName.checkBoxFixedOn), forState: .Normal)
            case .Complete:
                buttonCheckmark.setBackgroundImage(UIImage(named: Constants.ImageName.checkInBox), forState: .Normal)
            }
        }
    }
    
    private var chooserViews: [MediaChooserView]?
    
    private var version : UWVersion! {
        didSet { updateContents() }
    }

    static func createWithInfo(info:VersionSharingInfo) -> VersionChooserView {
        let view = UINib.viewForName(NSStringFromClass(VersionChooserView).textAfterLastPeriod()) as! VersionChooserView
        view.sharingInfo = info
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    @IBAction func userPressedCheckmarkButton(sender: UIButton)
    {
        let changeToState: CheckState
        if state == .Partial || state == .Complete {
            changeToState = .None
        } else {
            changeToState = .Complete
        }
        updateAllViewsWithCompleteState(changeToState)
    }
    
    /// Returns the sharing information, if any options are checked
    private func updateSharingInfo()
    {
        guard let types = chooserViews?.filter({ $0.isChecked }).map({ $0.getType() })
            else { assertionFailure("Something went wrong -- no views"); return }
        
        var options = DownloadOptions.Empty
        types.forEach { (type) -> () in
            switch type {
            case .None:
                assertionFailure("Should never encounter a type of .None")
            case .Text:
                options = options.union(.Text)
            case .Audio:
                options = options.union(.Audio)
            case .Video:
                options = options.union(.Video)
            }
        }
        sharingInfo.options = options
    }
    
    func updateCellsBasedOnSharingInfo()
    {
        version = sharingInfo.version
        guard let chooserViews = chooserViews else { assertionFailure("Wrong!"); return }
        
        chooserViews.forEach { (view) -> () in
            switch view.getType() {
            case .Text:
                if sharingInfo.options.contains(.Text) {
                    view.isChecked = true
                }
            case .Audio:
                if sharingInfo.options.contains(.Audio) {
                    view.isChecked = true
                }
            case .Video:
                if sharingInfo.options.contains(.Video) {
                    view.isChecked = true
                }
            case .None:
                break;
            }
        }
    }
    
    // MARK: - Helpers
    
    private func updateContents()
    {
        labelVersionName.text = version.name
        removeExistingChooserViews()
        addMediaChooserViews()
        setNeedsLayout()
    }
    
    private func showCheckingInfo() {
        showDialog(VerseVerifyInfoView.verifyViewForVersion(version))
    }
    
    // MARK: - CreatingViews
    
    private func updateAllViewsWithCompleteState(changedState: CheckState?) {
        guard let chooserViews = chooserViews else { assertionFailure("No Choosers!"); return }
        if let changedState = changedState { // Okay, we changed the main button
            switch changedState {
            case .None:
                chooserViews.forEach( { $0.isChecked = false })
            case .Partial:
                assertionFailure("Should not be able to set partial state.")
                return
            case .Complete:
                chooserViews.forEach( { $0.isChecked = true })
            }
            state = changedState
        }
        else {
            let count = chooserViews.reduce(0, combine: { (count, view) -> Int in
                return view.isChecked ? count+1 : count
            })
            if count == chooserViews.count {
                state = .Complete
            } else if count > 0 && count < chooserViews.count {
                state = .Partial
            } else if count == 0 {
                state = .None
            } else {
                assertionFailure("Could not deal with a check count of \(count)")
            }
        }
        updateSharingInfo()
    }
    
    private func addMediaChooserViews() {
        
        chooserViews = version.downloadedMediaTypes()?.map(createMediaChooserViewWithType)
        
        guard let views = chooserViews else {
            assertionFailure("NO available views for version \(version)")
            return
        }
        
        var previousView : UIView = buttonCheckmark
        
        views.forEach { (view) -> () in
            addSubview(view)
            self.addConstraints( NSLayoutConstraint.constraintsToFloatView(view, belowView: previousView, padding: 1, withContainerView: self, leftMargin: 34, rightMargin: 16) )
            previousView = view
        }
        
        addConstraint( NSLayoutConstraint(item: self, attribute: .Bottom, relatedBy: .Equal, toItem: previousView, attribute: .Bottom, multiplier: 1, constant: 0))
    }
    
    private func createMediaChooserViewWithType(type: MediaType) -> MediaChooserView {
        let view = MediaChooserView.createWithType(type)
        view.buttonCheckingLevel.setBackgroundImage(imageForCheckingLevel((version.status.checking_level as NSString).integerValue), forState: .Normal)
        view.checkmarkMarkBlock = { [weak self] () -> Void in
            self?.updateAllViewsWithCompleteState(nil)
        }
        view.checkingLevelBlock = { [weak self] () -> Void in
            self?.showCheckingInfo()
        }
        return view
    }
    
    private func removeExistingChooserViews() {
        guard let chooserViews = chooserViews else { return }
        chooserViews.forEach { $0.removeFromSuperview() }
    }
}
