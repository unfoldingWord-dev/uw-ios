//
//  ContainerVC.swift
//  UnfoldingWord
//
//  Created by David Solberg on 9/4/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

import Foundation
import UIKit

class ContainerVC: UIViewController {
    
    typealias AudioActionBlock = (barButton : UIBarButtonItem, isOn: Bool) -> (toc : UWTOC?, chapterIndex : Int?, setToOn: Bool)
    typealias FontActionBlock = (size : FontSize, font : UIFont, brightness: Float) -> Void
    typealias VideoActionBlock = (barButton : UIBarButtonItem, isOn: Bool) -> (toc : UWTOC?, chapterIndex : Int?, setToOn: Bool)
    typealias DiglotActionBlock =  (barButton : UIBarButtonItem, isOn: Bool) -> Void
    typealias ShareActionBlock = (barButton : UIBarButtonItem) -> (UWTOC?)
    
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
    
    @IBOutlet weak var contraintToolbarSpaceToBottom: NSLayoutConstraint!
    @IBOutlet weak var constraintAccessorySpaceToToolBar: NSLayoutConstraint!
    
    var topContainer : UWTopContainer? = nil
    var containerVC : UFWContainerUSFMVC? = nil
    
    var actionSpeaker : AudioActionBlock?
    var actionVideo : VideoActionBlock?
    var actionFont : FontActionBlock?
    var actionDiglot : DiglotActionBlock?
    var actionShare: ShareActionBlock?
    
    var playerViewAudio : AudioPlayerView?
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        turnOffAllBarButtons()
        updateAccessoryUI(isShowing: false, duration: 0)
        
        assert(topContainer != nil, "The top container must be present when the view loads")

        if let topContainer = self.topContainer { // no reason to crash if we're not using asserts
            let sb = UIStoryboard(name: "USFM", bundle: nil)
            let theContainerVC: UFWContainerUSFMVC = sb.instantiateViewControllerWithIdentifier("UFWContainerUSFMVC") as! UFWContainerUSFMVC
            theContainerVC.topContainer = topContainer
            theContainerVC.masterContainer = self
            theContainerVC.view.translatesAutoresizingMaskIntoConstraints = false
            self.viewMainContent.addSubview(theContainerVC.view)
            let constraints = NSLayoutConstraint.constraintsForView(theContainerVC.view, insideView: self.viewMainContent, topMargin: 0, bottomMargin: 0, leftMargin: 0, rightMargin: 0) as! [NSLayoutConstraint]
            self.viewMainContent.addConstraints(constraints)
            self.containerVC = theContainerVC
        }
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
        print("Implement")
        
    }
    
    @IBAction func userPressedShareButton(barButton: UIBarButtonItem) {
        print("Implement")
        
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
        let constraints = NSLayoutConstraint.constraintsForView(view, insideView: viewAccessories, topMargin: 0, bottomMargin: 0, leftMargin: 0, rightMargin: 0) as! [NSLayoutConstraint]
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
    
    private func animateContstraintChanges(duration duration : NSTimeInterval, completion : (Bool) -> Void ) {
        self.view.setNeedsUpdateConstraints()
        
        UIView.animateWithDuration(duration, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }) { (didComplete) -> Void in
                completion(didComplete)
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
        animateContstraintChanges(duration: duration) { (didComplete) -> Void in }
    }
    
    private func updateToolbarUI(isShowing isShowing : Bool, duration: NSTimeInterval) {
        let hidden = toolbarBottom.frame.size.height * -1.0
        let distance : CGFloat = (isShowing) ? 0.0 : hidden
        contraintToolbarSpaceToBottom.constant = distance
        animateContstraintChanges(duration: duration) { (didComplete) -> Void in }
    }
    
}

