//
//  ContainerVC.swift
//  UnfoldingWord
//
//  Created by David Solberg on 9/4/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

import Foundation
import UIKit

protocol ChromeHidingProtocol : class {
    func setTopBottomHiddenPercent(percent : CGFloat)
    func animateTopBottomToShowing(showing : Bool)
}

class TOCResponse : NSObject {
    let toc : UWTOC?
    let chapter : Int?
    let isOn : Bool
    
    init(toc : UWTOC?, chapter : Int?, setToOn: Bool) {
        self.toc = toc
        self.chapter = chapter
        self.isOn = setToOn
    }
}

typealias AudioActionBlock = (barButton : UIBarButtonItem, isOn: Bool) -> (toc : UWTOC?, chapter : Int?, setToOn: Bool)
typealias FontActionBlock = (size : CGFloat, font : UIFont, brightness: Float) -> Void
typealias VideoActionBlock = (barButton : UIBarButtonItem, isOn: Bool) -> (toc : UWTOC?, chapter : Int?, setToOn: Bool)
typealias DiglotActionBlock =  (barButton : UIBarButtonItem, didChangeToOn: Bool) -> Void
typealias ShareActionBlock = (barButton : UIBarButtonItem) -> (UWTOC?)
typealias ContainerDidSetTopBottomPercentHiddenBlock = (percent : CGFloat) -> Void

class ContainerVC: UIViewController, FakeNavBarDelegate, ChromeHidingProtocol, FontSizeProtocol {
    
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
    
    var blockTopBottomHidden : ContainerDidSetTopBottomPercentHiddenBlock?
    
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
    var openBibleVC : FrameDetailsViewController? = nil
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        playerViewAudio?.pause()
    }
    
    func animateTopBottomToShowing(showing : Bool)
    {
        updateToolbarUI(isShowing: showing, duration: 0.25)
        updateNavUI(isShowing: showing, duration: 0.25)

        dispatch_after(dispatch_time( DISPATCH_TIME_NOW, Int64(0.26 * Double(NSEC_PER_SEC))
            ), dispatch_get_main_queue()) { [weak self] () -> Void in
                self?.updateMainContentPercentHidden(showing ? 0.0 : 1.0)
        }
    }
    
    func updateMainContentPercentHidden(percent : CGFloat) {
        if let percentBlock = blockTopBottomHidden {
            percentBlock(percent: percent)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = BACKGROUND_GREEN()
        self.toolbarBottom.barTintColor = BACKGROUND_GREEN()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        turnOffAllBarButtons()
        
        updateAccessoryUI(isShowing: false, duration: 0)
        
        guard
            let language = topContainer.languages.first as? UWLanguage,
            let version = language.versions.first as? UWVersion,
            let toc = version.toc.first as? UWTOC
        else { return }
        
        if toc.isUSFMValue { // Add USFM VC
            let sb = UIStoryboard(name: "USFM", bundle: nil)
            let theContainerVC: USFMPageViewController = sb.instantiateViewControllerWithIdentifier("USFMPageViewController") as! USFMPageViewController
            self.usfmPageVC = theContainerVC
            theContainerVC.fakeNavBar = fakeNavBar
            theContainerVC.delegateChromeProtocol = self
            theContainerVC.addMasterContainerBlocksToContainer(self)
            autoAddChildViewController(theContainerVC, toViewInSelf: viewMainContent)
        }
        else { // Add Open Bible Stories Frame View Controller
            let flow = UICollectionViewFlowLayout()
            flow.scrollDirection = UICollectionViewScrollDirection.Horizontal
            flow.minimumLineSpacing = 0
            flow.minimumInteritemSpacing = 0
            flow.sectionInset = UIEdgeInsetsZero
            let frameDetail = FrameDetailsViewController(collectionViewLayout: flow)
            frameDetail.topContainer = topContainer
            frameDetail.fakeNavBar = fakeNavBar
            frameDetail.addMasterContainerBlocksToContainer(self)
            autoAddChildViewController(frameDetail, toViewInSelf: viewMainContent)
            openBibleVC = frameDetail
        }
        
        updateDiglotState(isOn: UFWSelectionTracker.isShowingSide())
    }

    
    private func updateDiglotState(isOn isOn : Bool) {
        setBarButton(barButtonDiglot, toOn: isOn)

        fakeNavBar.sideBarState = isOn ? .MainPlusSide : .MainOnly
        
        if let pageVC = usfmPageVC {
            pageVC.changeDiglotToShowing(isOn)
        }
    }

    @IBAction func userPressSpeakerButton(barButton: UIBarButtonItem) {
        
        setBarButton(barButtonFont, toOn: false)
        
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
            if let toc = response.toc where response.setToOn == true,
                let chapter = response.chapter,
                let url = NSURL(string: "https://api.unfoldingword.org/uw/audio/beta/01-GEN-br256.mp3") where response.setToOn == true
                // toc.urlAudioForChapter(chapter)
            {
                    insertAudioPlayerIntoAccessoryViewWithUrl(url)
                    setBarButton(barButton, toOn: true)
                    ensureAccessoryViewIsInState(showing: true)
            }
            else {
                setBarButton(barButton, toOn: false)
                ensureAccessoryViewIsInState(showing: false)
                UIAlertView(title: "Not Found", message: "This chapter does not have matching audio", delegate: nil, cancelButtonTitle: "Dismiss").show()
            }
        }
    }
    
    @IBAction func userPressedVideoButton(sender: AnyObject) {
        print("Implement")
        animateHideFont()
    }
    
    @IBAction func userPressedFontButton(barButton: UIBarButtonItem) {
        if isBarButtonOn(barButton) {
            animateHideFont()
            return
        }
        else {
            setBarButton(barButton, toOn: true)
            insertFontPickersIntoAccessoryView()
            ensureAccessoryViewIsInState(showing: true)
        }
    }
    
    private func animateHideFont() {
        if isBarButtonOn(barButtonFont) == false {
            return
        }
        setBarButton(barButtonFont, toOn: false)
        if let player = playerViewAudio where player.isPlaying() {
            insertAccessoryView(player)
        }
        else {
            ensureAccessoryViewIsInState(showing: false)
        }
    }
    
    @IBAction func userPressedDiglotButton(barButton: UIBarButtonItem) {
        animateHideFont()

        let currentState = !isBarButtonOn(barButton)
        updateDiglotState(isOn: currentState)

        if let action = self.actionDiglot {
            action(barButton: barButton, didChangeToOn: currentState)
        }
    }
    
    @IBAction func userPressedShareButton(barButton: UIBarButtonItem) {
        animateHideFont()
        
        if let action = self.actionShare, let toc = action(barButton: barButton) {
            sendFileForVersion(toc.version, fromBarButtonOrView: barButton)
        }
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
        else if let frameVC = openBibleVC {
            switch area {
            case .Main:
                return frameVC.tocFromIsSide(false)
            case .Side:
                return frameVC.tocFromIsSide(true)
            }
        }
        return nil
    }
    
    func expandToFullSize() {
        animateTopBottomToShowing(true)
    }
    
    func navBackButtonPressed() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    func navButtonPressed(button : ACTLabelButton, type : NavButtonType) {
        animateHideFont()

        switch type {
        case .VersionMain:
            showVersionPickerForArea(.Main)
        case .VersionSide:
            showVersionPickerForArea(.Side)
        case .BookChapter:
            showBookPicker()
        }
    }
    
    // Pickers
    
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
                pageVC.tocSide = matchingTOCFromTOC(toc, forNewArea: .Side)
            case .Side:
                pageVC.tocSide = toc
                pageVC.tocMain = matchingTOCFromTOC(toc, forNewArea: .Main)
            }
            pageVC.updateChapterVCs()
        }
        else if let openBibleVC = openBibleVC {
            switch area {
            case .Main:
                openBibleVC.processTOCPicked(toc, isSide: false)
            case .Side:
                openBibleVC.processTOCPicked(toc, isSide: true)
            }
            // Add the Open Bible Stories Here
        }
    }
    
    private func matchingTOCFromTOC(toc : UWTOC?, forNewArea area : TOCArea) -> UWTOC? {
        guard let toc = toc else {return nil}
        guard let _ = toc.slug else { return nil }
        guard let existingTOC = tocForArea(area) else {return nil }
        
        var matchingTOC : UWTOC? = nil
        
        for (_, candidateTOC) in existingTOC.version.toc.enumerate() {
            
            guard let candidateTOC = candidateTOC as? UWTOC else { break }
            guard let candSlug = candidateTOC.slug else { break }
            
            if toc.slug.isEqual(candSlug) {
                matchingTOC = candidateTOC
                break
            }
        }
        return matchingTOC
    }
    
    
    private func selectChapter(chapterNum : Int) {
        if let _ = usfmPageVC {
            usfmPageVC?.currentChapterNumber = chapterNum
            usfmPageVC?.updateChapterVCs()
            
        }
        else {
            // Add the Open Bible Stories Here
        }
    }
    
//    - (void)userRequestedBookPicker:(id)sender
//    {
//    //    __weak typeof(self) weakself = self;
//    //    UIViewController *navVC = [ChapterListTableViewController navigationChapterPickerWithTopContainer:self.chapterMain.container.toc.version.language.topContainer completion:^(BOOL isCanceled, OpenChapter *selectedChapter) {
//    //        if (isCanceled == NO && selectedChapter != nil) {
//    //            OpenChapter *sideChapter = [weakself.chapterSide.container matchingChapter:selectedChapter];
//    //            [weakself resetMainChapter:selectedChapter sideChapter:sideChapter];
//    //        }
//    //        [weakself dismissViewControllerAnimated:YES completion:^{}];
//    //    }];
//    //    [self presentViewController:navVC animated:YES completion:^{}];
//    }
    
    private func showBookPicker() {
        
        guard let toc = tocForArea(.Main) else {
            print("Requested toc, but was empty")
            return
        }
        
        if let _ = usfmPageVC {
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
        else if let openBibleVC = openBibleVC {
            let navVC = ChapterListTableViewController.navigationChapterPickerCompletion({ [weak self] (isCanceled : Bool, chapter : OpenChapter?) -> Void in
                guard let strongself = self else { return }
                strongself.dismissViewControllerAnimated(true, completion: { () -> Void in })
                if let mainChapter = chapter where isCanceled == false,
                    let sidetoc = strongself.tocForArea(.Side) {
                    let sideChapter = sidetoc.openContainer.matchingChapter(mainChapter)
                    openBibleVC.resetMainChapter(mainChapter, sideChapter: sideChapter)
                }
            })
            presentViewController(navVC, animated: true) { () -> Void in  }
        }
    }
    
    
    // Helpers
    
    private func insertFontPickersIntoAccessoryView() {
        let fontPicker = FontSizePickerView.fontPicker()
        fontPicker.delegate = self
        insertAccessoryView(fontPicker)
    }
    //typealias FontActionBlock = (size : CGFloat, font : UIFont, brightness: Float) -> Void

    func userDidChangeFontToSize(pointSize : CGFloat) {
        if let action = actionFont {
            action(size: pointSize, font: UIFont.boldSystemFontOfSize(pointSize), brightness: 1)
        }
    }
    
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

        if isAccessoryViewShowing() == isShowing {
            return
        }
        else {
            delay(0.001, closure: { [weak self] () -> Void in
                guard let sself = self else { return }
                sself.updateAccessoryUI(isShowing: isShowing, duration: 0.25)
            })
            
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
    }
    
    func turnOffAllBarButtons() {
        for bbi in userToolbarButtons {
            bbi.tintColor = colorOff
        }
    }
    
    // Showing and hiding stuff
    
    override func animateContstraintChanges(duration duration : NSTimeInterval, completion : (Bool) -> Void ) {
        
        UIView.animateWithDuration(duration, delay: 0.00, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            self.view.setNeedsUpdateConstraints()
            self.view.layoutIfNeeded()
            self.fakeNavBar.setNeedsUpdateConstraints()
            self.view.layoutIfNeeded()
            
            }) { (didComplete) -> Void in
                completion(didComplete)
        }
    }
    
    func setTopBottomHiddenPercent(percent : CGFloat)
    {
        animateHideFont()
        
        let fakeNavBarHeight = ((fakeNavBar.maximumHeight - fakeNavBar.minimumHeight) * (1-percent) ) + fakeNavBar.minimumHeight
        assert(fakeNavBarHeight >= fakeNavBar.minimumHeight, "fake nav bar wrong height")
        constraintFakeNavHeight.constant = fakeNavBarHeight
        
        let distanceToolbar = -toolbarBottom.frame.height * percent
        constraintToolbarSpaceToBottom.constant = distanceToolbar
        
        self.view.setNeedsUpdateConstraints()
        self.view.layoutIfNeeded()
        self.fakeNavBar.setNeedsUpdateConstraints()
        self.view.layoutIfNeeded()
    }
    
    private func updateNavUI(isShowing isShowing : Bool, duration: NSTimeInterval) {
        
        constraintFakeNavHeight.constant = isShowing ? fakeNavBar.maximumHeight : fakeNavBar.minimumHeight
        animateConstraintChanges(duration)
    }
    
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

