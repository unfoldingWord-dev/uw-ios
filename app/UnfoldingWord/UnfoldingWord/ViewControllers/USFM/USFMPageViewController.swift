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
    let textAlignment : NSTextAlignment?
    let chapter : USFMChapter?
    let toc : UWTOC?
}

protocol ChapterVCDelegate : class {
    func showNextTOC()
}

class USFMPageViewController : UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, ChapterVCDelegate {
    
    private var arrayMainChapters: [USFMChapter]?
    private var arraySideChapters: [USFMChapter]?
    
    var fakeNavBar : FakeNavBarView! // Assign on creation of this VC. Otherwise, it should crash!
    
    var tocMain : UWTOC?  {
        didSet {
            arrayMainChapters = chaptersFromTOC(tocMain)
            UFWSelectionTracker.setUSFMTOC(tocMain)
            updateNavBarTOCForArea(.Main)
        }
    }
    var tocSide : UWTOC? {
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
    
    var currentChapterNumber : Int! {
        didSet {
            UFWSelectionTracker.setChapterUSFM(currentChapterNumber)
            updateNavBarChapterInfo()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.currentChapterNumber = UFWSelectionTracker.chapterNumberUSFM()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.currentChapterNumber = UFWSelectionTracker.chapterNumberUSFM()
        self.dataSource = self
        self.delegate = self
        isShowingSideView = UFWSelectionTracker.isShowingSide()
        tocMain = UFWSelectionTracker.TOCforUSFM()
        tocSide = UFWSelectionTracker.TOCforUSFMSide()
        self.loadCurrentContentAnimated(false)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        for (_, view) in self.view.subviews.enumerate() {
            if view.isKindOfClass(UIScrollView) {
                let scrollview = view as! UIScrollView
                if scrollview.constraints.count == 0, let constraints = NSLayoutConstraint.constraintsForView(scrollview, insideView: self.view, topMargin: 0, bottomMargin: 0, leftMargin: 0, rightMargin: 0) {
                        scrollview.translatesAutoresizingMaskIntoConstraints = false
                        self.view.addConstraints(constraints)
                }
            }
        }
    }
    
    func updateNavBarChapterInfo() {
        
        let title : String
        if let toc = UFWSelectionTracker.TOCforUSFM() {
            title = "\(toc.title) \(UFWSelectionTracker.chapterNumberUSFM())"
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
    func addMasterContainerBlocksToContainer(masterContainer : ContainerVC) {
        
        //   typealias AudioActionBlock = (barButton : UIBarButtonItem, isOn: Bool) -> (toc : UWTOC?, chapterIndex : Int?, setToOn: Bool)
        masterContainer.actionSpeaker = { [weak self] (barButton : UIBarButtonItem, isOn: Bool) in
            if isOn == false, let strongself = self {
                if let toc = strongself.tocMain {
                    return (toc, strongself.currentChapterNumber, true)
                }
                else if let toc = strongself.tocSide {
                    return (toc, strongself.currentChapterNumber, true)
                }
            }
            return (nil, nil, false)
        }
        
        //    typealias DiglotActionBlock =  (barButton : UIBarButtonItem, isOn: Bool) -> Void
        masterContainer.actionDiglot = { [weak self] (barButton : UIBarButtonItem, didChangeToOn: Bool) in
            if let strongself = self {
                strongself.changeDiglotToShowing(didChangeToOn)
            }
        }
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

        switch area {
        case .Main:
            currentController.mainAttributes = attributesForArea(.Main)
        case .Side:
            currentController.sideAttributes = attributesForArea(.Side)
        }
        
        currentController.loadContentForArea(area, setToTop:true)
    }
    
    
    
    // ChapterVCDelegate Methods
    
    func showNextTOC() {
        tocMain = tocAfterTOC(tocMain)
        tocSide = tocAfterTOC(tocSide)
        currentChapterNumber  = 1
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
        setViewControllers([chapterVC(currentChapterNumber)], direction: UIPageViewControllerNavigationDirection.Forward, animated: isAnimated) { (didComplete : Bool) -> Void in }
    }
    
    private func chapterVC(chapterNum : Int) -> USFMChapterVC {
        let chapterVC : USFMChapterVC = self.storyboard!.instantiateViewControllerWithIdentifier("USFMChapterVC") as! USFMChapterVC
        chapterVC.mainAttributes = attributesForArea(.Main)
        chapterVC.sideAttributes = attributesForArea(.Side)
        chapterVC.chapterNumber = chapterNum
        chapterVC.delegate = self
        return chapterVC
    }
    
    private func attributesForArea(area : TOCArea) -> AreaAttributes {
        
        let toc : UWTOC?
        let nextChapterText : String?
        let textAlignment : NSTextAlignment?
        let chapter : USFMChapter?
        
        if let foundToc = tocForArea(area) {
            toc = foundToc
            textAlignment = LanguageInfoController.textAlignmentForLanguageCode(foundToc.version.language.lc)
        }
        else {
            toc = nil
            textAlignment = nil
        }
        
        if let chapters = chaptersForArea(area) {
            if currentChapterNumber >= chapters.count {
                if let toc = toc, let nextToc = tocAfterTOC(toc) {
                    let gotoPrefix = NSLocalizedString("Go to", comment: "Name of bible chapter goes after this text")
                    nextChapterText = "\(gotoPrefix) \(nextToc.title)"
                }
                else {
                    nextChapterText = "Next Chapter"
                }
                chapter = nil
            }
            else {
                chapter = chapters[currentChapterNumber]
                nextChapterText = nil
            }
        }
        else {
            chapter = nil
            nextChapterText = nil
        }
        
        let attributes = AreaAttributes(nextChapterText: nextChapterText, textAlignment: textAlignment, chapter: chapter, toc: toc)
        return attributes
    }

    
    // Page View Controller Delegate
    
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
//        if pendingViewControllers.count > 0 {
//            let existingVC = pendingViewControllers[0] as! USFMChapterVC
//            currentChapterNumber = existingVC.chapterNumber
//        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentVC = currentChapterVC() {
            currentChapterNumber = currentVC.chapterNumber
        }
    }
    
    // Page View Controller Data Sourche
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
        
        if existingVC.chapterNumber >= anyArray().count {
            return nil
        }
        else {
            return chapterVC(existingVC.chapterNumber + 1)
        }
    }
    
//    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
//        return anyArray().count
//    }
//    
//    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
//        return currentChapterNumber
//    }
    
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
        if let toc = toc, chapters = toc.usfmInfo.chapters() as? [USFMChapter] {
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