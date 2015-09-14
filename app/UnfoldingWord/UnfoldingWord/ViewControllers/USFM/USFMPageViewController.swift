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

class USFMPageViewController : UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    private var arrayMainChapters: [USFMChapter]?
    private var arraySideChapters: [USFMChapter]?
    
    var tocMain : UWTOC? = UFWSelectionTracker.TOCforUSFM() {
        didSet {
            arrayMainChapters = chaptersFromTOC(tocMain)
            UFWSelectionTracker.setUSFMTOC(tocMain)
        }
    }
    var tocSide : UWTOC? = UFWSelectionTracker.TOCforUSFMSide() {
        didSet {
            arrayMainChapters = chaptersFromTOC(tocSide)
            UFWSelectionTracker.setUSFMTOCSide(tocSide)
        }
    }

    private var isShowingSideView : Bool  {
        get {
            return UFWSelectionTracker.isShowingSide()
        }
        set {
            UFWSelectionTracker.setIsShowingSide(isShowingSideView)
        }
    }
    
    private var currentChapterNumber : Int {
        get {
            return UFWSelectionTracker.chapterNumberUSFM()
        }
        set {
            UFWSelectionTracker.setChapterUSFM(currentChapterNumber)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
    }
    
    // Public
    func changeDiglot() {
        
        if let controllers = self.viewControllers where controllers.count > 0 {
            let currentController = controllers[0] as! USFMChapterVC
            if isShowingSideView {
                currentController.hideDiglotAnimated(true)
            }
            else {
                currentController.showDiglotAnimated(true)
            }
        }
        
        let isShowing = isShowingSideView
        isShowingSideView = !isShowing
    }
    
    
    // Private
    
    private func loadCurrentContentAnimated(isAnimated : Bool) {
        setViewControllers([chapterVC(currentChapterNumber)], direction: UIPageViewControllerNavigationDirection.Forward, animated: isAnimated) { (didComplete : Bool) -> Void in }
    }
    
    private func chapterVC(chapterNum : Int) -> USFMChapterVC {
        let chapterVC : USFMChapterVC = self.storyboard!.instantiateViewControllerWithIdentifier("USFMChapterVC") as! USFMChapterVC
        chapterVC.mainAttributes = attributesForArea(.Main)
        chapterVC.sideAttributes = attributesForArea(.Side)
        chapterVC.chapterNumber = chapterNum
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
            if chapters.count >= currentChapterNumber {
                chapter = nil
                let gotoPrefix = NSLocalizedString("Go to", comment: "Name of bible chapter goes after this text")
                nextChapterText = "\(gotoPrefix) \(title)"
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
    
    private func showVersionPickerForArea(area : TOCArea) -> Bool {
        
        guard let toc = tocForArea(area) else {
            print("Requested toc, but was empty")
            return false
        }
        
        let navVC = UFWVersionPickerVC.navigationLanguagePickerWithTOC(toc) { [weak self] (isCanceled : Bool, versionPicked : UWVersion?) -> Void in

            guard let strongself = self else { return }
            strongself.dismissViewControllerAnimated(true, completion: { () -> Void in })
            
            guard let versionPicked = versionPicked, arrayTOCS = versionPicked.sortedTOCs() as? [UWTOC] where arrayTOCS.count > 0  && isCanceled == false else { return }
            
            if let initialSlug = toc.slug {
                let results = arrayTOCS.filter {
                    if let candidateSlug = $0.slug where candidateSlug.isEqual(initialSlug) {
                        return true
                    }
                    return false
                }
                assert(results.count == 1, "There should be exactly one TOC that matches!! Instead there were \(results.count)")
                if results.count >= 1 {
                    strongself.selectTOC(results[0], forArea: area)
                    strongself.loadCurrentContentAnimated(false)
                    return
                }
            }
        
            // Fall through
            strongself.selectTOC(arrayTOCS[0], forArea: area)
            strongself.loadCurrentContentAnimated(false)
        }
        presentViewController(navVC, animated: true) { () -> Void in }
        return true
    }
    
    private func showBookPickerForArea(area : TOCArea) {
        
        guard let toc = tocForArea(area) else {
            print("Requested toc, but was empty")
            return
        }
        
        let navVC = UFWBookPickerUSFMVC.navigationBookPickerWithVersion(toc.version) { [weak self] (isCanceled : Bool, toc : UWTOC?, chapterPicked : Int) -> Void in
            guard let strongself = self else { return }
            strongself.dismissViewControllerAnimated(true, completion: { () -> Void in })
            
            let chapter = chapterPicked > 0 ? chapterPicked : 1
            if let toc = toc {
                strongself.selectTOC(toc, forArea: area)
                strongself.currentChapterNumber = chapter
                strongself.loadCurrentContentAnimated(false)
            }
        }
        presentViewController(navVC, animated: true) { () -> Void in  }
    }
    
    // Page View Controller Delegate
    
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
        if pendingViewControllers.count > 0 {
            let existingVC = pendingViewControllers[0] as! USFMChapterVC
            currentChapterNumber = existingVC.chapterNumber
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
    }
    
    // Page View Controller Data Sourche
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        let existingVC = viewController as! USFMChapterVC
        
        if existingVC.chapterNumber == 1 {
            return nil
        }
        else {
            currentChapterNumber = existingVC.chapterNumber - 1
            return chapterVC(currentChapterNumber)
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        let existingVC = viewController as! USFMChapterVC
        
        if existingVC.chapterNumber >= anyArray().count {
            return nil
        }
        else {
            currentChapterNumber = existingVC.chapterNumber + 1
            return chapterVC(currentChapterNumber)
        }
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return anyArray().count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return currentChapterNumber
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
    
    private func tocAfterTOC(toc : UWTOC) -> UWTOC? {
        
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