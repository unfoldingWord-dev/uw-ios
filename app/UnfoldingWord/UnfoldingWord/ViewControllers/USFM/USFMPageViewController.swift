//
//  USFMPageViewController.swift
//  UnfoldingWord
//
//  Created by David Solberg on 9/8/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

import Foundation

enum TOCArea {
    case Main
    case Side
}

struct AreaAttributes {
    var isNextChapter : Bool {
        get {
            return nextChapterText != nil
        }
    }
    var isEmpty : Bool {
        get {
            return chapter == nil
        }
    }
    let nextChapterText : String?
    let chapter : USFMChapter?
    let toc : UWTOC?
}

protocol ChapterVCDelegate : ChromeHidingProtocol {
    func showNextTOC()
}

class USFMPageViewController : UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, ChapterVCDelegate, ChromeHidingProtocol {
    
    private var arrayMainChapters: [USFMChapter]?
    private var arraySideChapters: [USFMChapter]?
        
    var fakeNavBar : FakeNavBarView! // Assign on creation of this VC. Otherwise, it should crash!
    
    var tocMain : UWTOC? = nil {
        didSet {
            arrayMainChapters = chaptersFromTOC(tocMain)
            UFWSelectionTracker.setUSFMTOC(tocMain)
            updateNavBarTOCForArea(.Main)
        }
    }
    var tocSide : UWTOC? = nil {
        didSet {
            arraySideChapters = chaptersFromTOC(tocSide)
            UFWSelectionTracker.setUSFMTOCSide(tocSide)
            updateNavBarTOCForArea(.Side)
        }
    }

    private var isShowingSideView : Bool!  {
        didSet {
            UFWSelectionTracker.setIsShowingSide(isShowingSideView)
        }
    }
    
    weak var delegateChromeProtocol : ChromeHidingProtocol?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        isShowingSideView = UFWSelectionTracker.isShowingSide()
        tocMain = UFWSelectionTracker.TOCforUSFM()
        tocSide = UFWSelectionTracker.TOCforUSFMSide()
        self.loadCurrentContentAnimated(false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        addConstaintsToInternalScrolling()
    }
    
    // The page view controller has an internal scrollview that does not update with constraint changes to its parent view. We're finding that scrollview, then adding constraints so that it follows its parent view. This does cause some issues with other things, but it's the only way I could figure out to make autolayout work when changing view sizes dynamically.
    private func addConstaintsToInternalScrolling() {
        
        for (_, view) in self.view.subviews.enumerate() {
            if view.isKindOfClass(UIScrollView) {
                let scrollview = view as! UIScrollView
                if scrollview.constraints.count == 0, let constraints = NSLayoutConstraint.constraintsForView(scrollview, insideView: self.view, topMargin: 0, bottomMargin: 0, leftMargin: 0, rightMargin: 0) {
                    scrollview.translatesAutoresizingMaskIntoConstraints = false
                    self.view.addConstraints(constraints)
                    self.view.setNeedsUpdateConstraints()
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    func setTopBottomHiddenPercent(percent : CGFloat)
    {
        if let delegateChromeProtocol = delegateChromeProtocol {
            delegateChromeProtocol.setTopBottomHiddenPercent(percent)
        }
    }
    
    func animateTopBottomToShowing(showing : Bool)
    {
        if let delegateChromeProtocol = delegateChromeProtocol {
            delegateChromeProtocol.animateTopBottomToShowing(showing)
        }
    }
    
    func updateNavBarChapterInfo() {
        
        let title : String
        if let toc = UFWSelectionTracker.TOCforUSFM() {
            title = "\(toc.chapterTitle) \(UFWSelectionTracker.chapterNumberUSFM())"
        }
        else {
            title = "Select Book"
        }
        fakeNavBar.labelButtonBookPlusChapter.text = title
    }
    
    func updateNavBarTOCForArea(area : TOCArea) {
        guard let toc = tocForArea(area) else {
            return
        }
        
        switch area {
        case .Main:
            fakeNavBar.labelButtonVersionMainAlone.text = toc.version.slug?.uppercaseString
            fakeNavBar.labelButtonSSVersionMain.text = toc.version.slug?.uppercaseString
        case .Side:
            fakeNavBar.labelButtonSSVersionSide.text = toc.version.slug?.uppercaseString
        }
        updateNavBarChapterInfo()
    }
    
    // Public
    
    func audioSourceWithChapter(chapter : Int, inAudio audio : UWAudio) -> UWAudioSource? {
        for (_, source) in audio.sources.enumerate() {
            let castSource = source as! UWAudioSource
            if let chapterString = castSource.chapter {
                let castString = chapterString as NSString
                let currentChapter = castString.integerValue
                if chapter == currentChapter {
                    return castSource
                }
            }
        }
        return nil
    }
    
    func addMasterContainerBlocksToContainer(masterContainer : ContainerVC) {
        
        masterContainer.actionSpeaker = { [weak self] () in
            if let strongself = self {
                let toc = strongself.tocMain != nil ? strongself.tocMain : strongself.tocSide
                if let audio = toc?.media?.audio {
                    let source = strongself.audioSourceWithChapter(UFWSelectionTracker.chapterNumberUSFM(), inAudio: audio)
                    return AudioInfo(source: source, frameOrVerse: nil)
                }
            }
            return AudioInfo(source: nil, frameOrVerse: nil)
        }
        
        masterContainer.actionDiglot = { [weak self] (barButton : UIBarButtonItem, didChangeToOn: Bool) in
            if let strongself = self {
                strongself.changeDiglotToShowing(didChangeToOn)
            }
        }
        
        masterContainer.actionVideo = { () in
            return VideoInfo(source: nil)
        }
        
        masterContainer.actionShare = { [weak self] (barButton : UIBarButtonItem) in
            guard let strongself = self else { return nil }
            if let toc = strongself.tocMain {
                return (toc)
            }
            else if let toc = strongself.tocSide {
                return (toc)
            }
            else {
                return nil
            }
        }
        
        masterContainer.actionFont = { [weak self] (size : CGFloat, font : UIFont, brightness: Float) in
            guard let strongself = self else { return }
            strongself.adjustFontSize(size)
        }
        
        masterContainer.blockTopBottomHidden = { [weak self] (percentHidden : CGFloat) in
            guard let strongself = self else { return }
            strongself.currentChapterVC()?.percentHidden = percentHidden
        }
    }
    
    func adjustFontSize(fontSize : CGFloat) {
        currentChapterVC()?.changePointSize(fontSize)
    }
    
    
    func changeDiglotToShowing(isShowing : Bool) {
        
        if isShowing == isShowingSideView {
            return
        }
        isShowingSideView = isShowing
        
        guard let currentController = currentChapterVC() else { return }

        if isShowing {
            currentController.showDiglotAnimated(true)
        }
        else {
            currentController.hideDiglotAnimated(true)
        }
    }
    
    func updateChapterVCs() {
        updateChapterVCForArea(.Main)
        updateChapterVCForArea(.Side)
    }
    
    func updateChapterVCForArea(area : TOCArea) {
        guard let currentController = currentChapterVC() else { return }
        
        currentController.chapterNumber = UFWSelectionTracker.chapterNumberUSFM();

        switch area {
        case .Main:
            currentController.mainAttributes = attributesForArea(.Main, forChapterInt: UFWSelectionTracker.chapterNumberUSFM())
        case .Side:
            currentController.sideAttributes = attributesForArea(.Side, forChapterInt: UFWSelectionTracker.chapterNumberUSFM())
        }
        
        currentController.loadContentForArea(area, setToTop:true)
        
        // This resets the view controllers that appear before and after the current one, which is necessary because they will likely change
        self.dataSource = nil;
        self.delegate = nil;
        delay(0.0) { () -> Void in
            self.dataSource = self;
            self.delegate = self;
        }
    }
    
    // ChapterVCDelegate Methods
    
    func showNextTOC() {
        tocMain = tocAfterTOC(tocMain)
        tocSide = tocAfterTOC(tocSide)
        UFWSelectionTracker.setChapterUSFM(1)
        updateNavBarChapterInfo()
        loadCurrentContentAnimated(true)
        
    }
    

    // Private
    private func currentChapterVC() -> USFMChapterVC? {
        if let controllers = self.viewControllers where controllers.count > 0,
            let currentController = controllers[0] as? USFMChapterVC {
                return currentController
        }
        else {
            return nil
        }
    }
    
    private func loadCurrentContentAnimated(isAnimated : Bool) {
        setViewControllers([chapterVC(UFWSelectionTracker.chapterNumberUSFM())], direction: UIPageViewControllerNavigationDirection.Forward, animated: isAnimated) { (didComplete : Bool) -> Void in }
    }
    
    private func chapterVC(chapterNum : Int) -> USFMChapterVC {
        let chapterVC : USFMChapterVC = self.storyboard!.instantiateViewControllerWithIdentifier("USFMChapterVC") as! USFMChapterVC
        chapterVC.mainAttributes = attributesForArea(.Main, forChapterInt: chapterNum)
        chapterVC.sideAttributes = attributesForArea(.Side, forChapterInt: chapterNum)
        chapterVC.chapterNumber = chapterNum
        chapterVC.delegate = self
        chapterVC.pointSize = UFWSelectionTracker.fontPointSize()
        return chapterVC
    }
    
    private func attributesForArea(area : TOCArea, forChapterInt chapterInt : Int) -> AreaAttributes {
        
        let toc : UWTOC? = tocForArea(area)
        let nextChapterText : String?
        let chapter : USFMChapter?
        
        if let chapters = chaptersForArea(area) {
            if chapterInt > chapters.count {
                if let toc = toc, let nextToc = tocAfterTOC(toc) {
                    let gotoPrefix = NSLocalizedString("Go to", comment: "Name of bible chapter goes after this text")
                    nextChapterText = "\(gotoPrefix) \(nextToc.chapterTitle)"
                }
                else {
                    nextChapterText = "Next Chapter"
                }
                chapter = nil
            }
            else {
                chapter = chapters[chapterInt-1]
                nextChapterText = nil
            }
        }
        else {
            chapter = nil
            nextChapterText = nil
        }
        
        let attributes = AreaAttributes(nextChapterText: nextChapterText, chapter: chapter, toc: toc)
        return attributes
    }

    
    // Page View Controller Delegate
    
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {}
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentVC = currentChapterVC() {
            if (currentVC.chapterNumber <= anyArray().count) {
                UFWSelectionTracker.setChapterUSFM(currentVC.chapterNumber)
                updateNavBarChapterInfo()
            }
        }
    }
    
    // Page View Controller Data Source
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        let existingVC = viewController as! USFMChapterVC
        
        if existingVC.chapterNumber == 1 {
            return nil
        }
        else {
            return chapterVC(existingVC.chapterNumber - 1)
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
                
        let existingVC = viewController as! USFMChapterVC
        
        if existingVC.chapterNumber > anyArray().count {
            return nil
        }
        else {
            return chapterVC(existingVC.chapterNumber + 1)
        }
    }
    
    // Helpers
        
        func anyArray() -> [USFMChapter] {
            if let arrayMain = arrayMainChapters {
                return arrayMain
            }
            else if let arraySide = arraySideChapters {
                return arraySide
            }
            else {
                return [USFMChapter]()
            }
        }
    
    private func selectTOC(toc : UWTOC, forArea area : TOCArea) {
        switch area {
        case .Main:
            tocMain = toc
        case .Side:
            tocSide = toc
        }
        updateChapterVCForArea(area)
    }
    
    func tocForArea(area : TOCArea) -> UWTOC? {
        switch area {
        case .Main:
            return tocMain
        case .Side:
            return tocSide
        }
    }
    
    private func chaptersForArea(area : TOCArea) -> [USFMChapter]? {
        switch area {
        case .Main:
            return arrayMainChapters
        case .Side:
            return arraySideChapters
        }
    }
    
    private func chaptersFromTOC(toc : UWTOC?) -> [USFMChapter]? {
        if let toc = toc, info = toc.usfmInfo, chapters = info.chapters() as? [USFMChapter] {
            return chapters
        }
        else {
            return nil
        }
    }
    
    private func tocAfterTOC(toc : UWTOC?) -> UWTOC? {
        
        guard let toc = toc else { return nil }
        
        let sortedTocs = toc.version.sortedTOCs() as! [UWTOC]
        for (i, aToc) in sortedTocs.enumerate() {
            if toc.isEqual(aToc) && (i+1) < sortedTocs.count {
                return sortedTocs[i+1]
            }
        }
        
        assertionFailure("Should never reach this point. Either there should not have been a next chapter button or else we failed to match the toc.")
        return nil
    }
    
}