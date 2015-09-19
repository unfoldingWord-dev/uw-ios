//
//  ContainerVC.swift
//  UnfoldingWord
//
//  Created by David Solberg on 9/4/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

import Foundation
import UIKit

typealias AudioActionBlock = (barButton : UIBarButtonItem, isOn: Bool) -> (toc : UWTOC?, chapterIndex : Int?, setToOn: Bool)
typealias FontActionBlock = (size : FontSize, font : UIFont, brightness: Float) -> Void
typealias VideoActionBlock = (barButton : UIBarButtonItem, isOn: Bool) -> (toc : UWTOC?, chapterIndex : Int?, setToOn: Bool)
typealias DiglotActionBlock =  (barButton : UIBarButtonItem, didChangeToOn: Bool) -> Void
typealias ShareActionBlock = (barButton : UIBarButtonItem) -> (UWTOC?)

class ContainerVC: UIViewController, FakeNavBarDelegate {
    
    var topContainer : UWTopContainer! // Must set before loading the view!
    
    let colorOn = UIColor(red: 0.0, green: 0.769, blue: 0.98, alpha: 1)
    let colorOff = UIColor.whiteColor()
    
    @IBOutlet weak var viewMainContent: UIView!
    @IBOutlet weak var viewAccessories: UIView!
    @IBOutlet weak var toolbarBottom: UIToolbar!
    
    // Bar Buttons
    @IBOutlet var userToolbarButtons: [UIBarButtonItem]!
    @IBOutlet weak var barButtonSpeaker: UIBarButtonItem!
    @IBOutlet weak var barButtonVideo: UIBarButtonItem!
    @IBOutlet weak var barButtonFont: UIBarButtonItem!
    @IBOutlet weak var barButtonDiglot: UIBarButtonItem!
    @IBOutlet weak var barButtonShare: UIBarButtonItem!
    
    @IBOutlet var constraintToolbarSpaceToBottom: NSLayoutConstraint!
    @IBOutlet var constraintAccessorySpaceToToolBar: NSLayoutConstraint!
    @IBOutlet var constraintFakeNavHeight : NSLayoutConstraint!

    var actionSpeaker : AudioActionBlock?
    var actionVideo : VideoActionBlock?
    var actionFont : FontActionBlock?
    var actionDiglot : DiglotActionBlock?
    var actionShare: ShareActionBlock?
    
    var playerViewAudio : AudioPlayerView?

    @IBOutlet weak var viewForFakeNavBar: UIView! {
        didSet {
            let nibViews = NSBundle.mainBundle().loadNibNamed("FakeNavBarView", owner: nil, options: nil)
            fakeNavBar = nibViews[0] as! FakeNavBarView
            fakeNavBar.translatesAutoresizingMaskIntoConstraints = false
            let constraints = NSLayoutConstraint.constraintsForView(fakeNavBar, insideView: viewForFakeNavBar, topMargin: 0, bottomMargin: 0, leftMargin: 0, rightMargin: 0)!
            viewForFakeNavBar.addSubview(fakeNavBar)
            viewForFakeNavBar.addConstraints(constraints)
            fakeNavBar.backgroundColor = BACKGROUND_GREEN()
            fakeNavBar.delegate = self
        }
    }
    
    var fakeNavBar: FakeNavBarView!
    
    
    var usfmPageVC : USFMPageViewController? = nil
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = BACKGROUND_GREEN()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        turnOffAllBarButtons()
        
        updateAccessoryUI(isShowing: false, duration: 0)
        
        let sb = UIStoryboard(name: "USFM", bundle: nil)
        let theContainerVC: USFMPageViewController = sb.instantiateViewControllerWithIdentifier("USFMPageViewController") as! USFMPageViewController
        self.usfmPageVC = theContainerVC
        theContainerVC.fakeNavBar = fakeNavBar
        theContainerVC.addMasterContainerBlocksToContainer(self)
        autoAddChildViewController(theContainerVC, toViewInSelf: viewMainContent)
        
        updateDiglotState(isOn: UFWSelectionTracker.isShowingSide())
    }
    
    private func updateDiglotState(isOn isOn : Bool) {
        setBarButton(barButtonDiglot, toOn: isOn)
        fakeNavBar.sideBarState = isOn ? .MainPlusSide : .MainOnly
        
        if let pageVC = usfmPageVC {
            pageVC.changeDiglotToShowing(isOn)
        }
        
        if (isOn) {
            constraintFakeNavHeight.constant = fakeNavBar.minimumHeight
            constraintToolbarSpaceToBottom.constant = 0 // -toolbarBottom.frame.size.height
        }
        else {
            constraintFakeNavHeight.constant = fakeNavBar.maximumHeight
            constraintToolbarSpaceToBottom.constant = 0
        }
        
        animateConstraintChanges()
    }


    @IBAction func userPressSpeakerButton(barButton: UIBarButtonItem) {
        
        if isBarButtonOn(barButton) {
            if let player = playerViewAudio where player.isPlaying() {
                player.pause()
            }
            ensureAccessoryViewIsInState(showing: false)
            setBarButton(barButton, toOn: false)
            return
        }
        else if let action = self.actionSpeaker {
            let response = action(barButton: barButton, isOn: isBarButtonOn(barButton))
            
            //////
            //WARNING: This is always the same. Remove when we have actual info
            //////
            
            if let _ = response.toc, url = NSURL(string: "https://api.unfoldingword.org/uw/audio/beta/01-GEN-br256.mp3") where response.setToOn == true {
                insertAudioPlayerIntoAccessoryViewWithUrl(url)
                setBarButton(barButton, toOn: true)
                ensureAccessoryViewIsInState(showing: true)
            }
            else {
                setBarButton(barButton, toOn: false)
                ensureAccessoryViewIsInState(showing: false)
            }
        }
    }
    
    @IBAction func userPressedVideoButton(sender: AnyObject) {
        print("Implement")
    }
    
    @IBAction func userPressedFontButton(barButton: UIBarButtonItem) {
        print("Implement")
        
    }
    
    @IBAction func userPressedDiglotButton(barButton: UIBarButtonItem) {
        let currentState = !isBarButtonOn(barButton)
        updateDiglotState(isOn: currentState)

        if let action = self.actionDiglot {
            action(barButton: barButton, didChangeToOn: currentState)
        }
    }
    
    @IBAction func userPressedShareButton(barButton: UIBarButtonItem) {
        print("Implement")
        
    }
    
    // Nav Bar Delegate
    
    func tocForArea(area : TOCArea) -> UWTOC? {
        if let pageVC = usfmPageVC {
            switch area {
            case .Main:
                return pageVC.tocMain
            case .Side:
                return pageVC.tocSide
            }
        }
        else {
            // Add the Open Bible Stories Here
            return nil
        }
    }
    
    func expandToFullSize() {
        self.constraintFakeNavHeight.constant = self.fakeNavBar.maximumHeight
        animateConstraintChanges()
    }
    
    func navBackButtonPressed() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    func navButtonPressed(button : ACTLabelButton, type : NavButtonType) {
        switch type {
        case .VersionMain:
            showVersionPickerForArea(.Main)
        case .VersionSide:
            showVersionPickerForArea(.Side)
        case .BookChapter:
            showBookPicker()
        }
    }
    
    
    private func showVersionPickerForArea(area : TOCArea) -> Bool {
        
        let navVC = UFWVersionPickerVC.navigationLanguagePickerWithTOC(tocForArea(area), topContainer: topContainer) {
            [weak self] (isCanceled : Bool, versionPicked : UWVersion?) -> Void in
            
            guard let strongself = self else { return }
            strongself.dismissViewControllerAnimated(true, completion: { () -> Void in })
            
            guard let versionPicked = versionPicked, arrayTOCS = versionPicked.sortedTOCs() as? [UWTOC] where arrayTOCS.count > 0  && isCanceled == false
                else { return }
            
            if let initialSlug = strongself.tocForArea(area)?.slug {
                let results = arrayTOCS.filter {
                    if let candidateSlug = $0.slug where candidateSlug.isEqual(initialSlug) {
                        return true
                    }
                    return false
                }
                assert(results.count == 1, "There should be exactly one TOC that matches!! Instead there were \(results.count)")
                if results.count >= 1 {
                    strongself.selectTOC(results[0], forArea: area)
                    return
                }
            }
            
            // Fall through
            strongself.selectTOC(arrayTOCS[0], forArea: area)
        }
        presentViewController(navVC, animated: true) { () -> Void in }
        return true
    }
    
    private func selectTOC(toc : UWTOC?, forArea area : TOCArea) {
        if let pageVC = usfmPageVC {
            switch area {
            case .Main:
                pageVC.tocMain = toc
            case .Side:
                pageVC.tocSide = toc
            }
        }
        else {
            // Add the Open Bible Stories Here
        }
    }
    
    private func selectChapter(chapterNum : Int) {
        if let _ = usfmPageVC {
            usfmPageVC?.chapterDidChange(chapterNum)
        }
        else {
            // Add the Open Bible Stories Here
        }
    }
    
    private func showBookPicker() {
        
        guard let toc = tocForArea(.Main) else {
            print("Requested toc, but was empty")
            return
        }
        
        let navVC = UFWBookPickerUSFMVC.navigationBookPickerWithVersion(toc.version) { [weak self] (isCanceled : Bool, toc : UWTOC?, chapterPicked : Int) -> Void in
            guard let strongself = self else { return }
            strongself.dismissViewControllerAnimated(true, completion: { () -> Void in })
            
            let chapter = chapterPicked > 0 ? chapterPicked : 1
            if let toc = toc {
                strongself.selectTOC(toc, forArea: TOCArea.Main)
                strongself.selectChapter(chapter)
            }
        }
        presentViewController(navVC, animated: true) { () -> Void in  }
    }
    
    
    // Helpers
    
    private func insertAudioPlayerIntoAccessoryViewWithUrl(url : NSURL) -> Bool {
        
        if let existingPlayer = playerViewAudio, existingUrl = existingPlayer.url where existingUrl == url {
            return true
        }
        else if let player = AudioPlayerView.playerWithUrl(url) {
            self.playerViewAudio = player
            insertAccessoryView(player)
            return true
        }
        else {
            return false
        }
    }
    
    private func insertAccessoryView(view : UIView) {
        for view in viewAccessories.subviews {
            view.removeFromSuperview()
        }
        viewAccessories.addSubview(view)
        let constraints = NSLayoutConstraint.constraintsForView(view, insideView: viewAccessories, topMargin: 0, bottomMargin: 0, leftMargin: 0, rightMargin: 0)!
        viewAccessories.addConstraints(constraints)
    }
    
    
    private func ensureAccessoryViewIsInState(showing isShowing : Bool) {
        let currentlyShowing = isAccessoryViewShowing()
        if currentlyShowing == isShowing {
            return
        }
        else {
            updateAccessoryUI(isShowing: isShowing, duration: 0.25)
        }
    }
    
    
    private func isAccessoryViewShowing() -> Bool {
        return constraintAccessorySpaceToToolBar.constant == 0 ? true : false
    }
    
    // Bar Button Actions
    
    private func isBarButtonOn(barButton : UIBarButtonItem) -> Bool {
        return  (barButton.tintColor == colorOn) ? true : false
    }
    
    private func setBarButton(barButton : UIBarButtonItem, toOn isOn: Bool) {
        
        barButton.tintColor = isOn ? colorOn : colorOff
        if isOn == true {
            turnOffAllButtonsExcept(barButton)
        }
    }
    
    func turnOffAllButtonsExcept(barButton : UIBarButtonItem) {
        
        for bbi in userToolbarButtons {
            if bbi.isEqual(barButton) {
                bbi.tintColor = colorOn
            }
            else {
                bbi.tintColor = colorOff
            }
        }
    }
    
    func turnOffAllBarButtons() {
        for bbi in userToolbarButtons {
            bbi.tintColor = colorOff
        }
    }
    
    // Showing and hiding bottom bars
    private func updateAccessoryUI(isShowing isShowing : Bool, duration: NSTimeInterval) {
        
        let hidden = viewAccessories.frame.size.height * -1.0
        let distance : CGFloat = (isShowing) ? 0.0 : hidden
        constraintAccessorySpaceToToolBar.constant = distance
        animateConstraintChanges(duration)
    }
    
    private func updateToolbarUI(isShowing isShowing : Bool, duration: NSTimeInterval) {
        let hidden = toolbarBottom.frame.size.height * -1.0
        let distance : CGFloat = (isShowing) ? 0.0 : hidden
        constraintToolbarSpaceToBottom.constant = distance
        animateConstraintChanges(duration)
    }
    
}

