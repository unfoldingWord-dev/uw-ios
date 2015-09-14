//
//  USFMPageViewController.swift
//  UnfoldingWord
//
//  Created by David Solberg on 9/8/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

import Foundation

class USFMPageViewController : UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    var tocMain : UWTOC?
    var tocSide : UWTOC?
    
    var chapterNumber : Int?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
    }
    
    private func selectTOC(toc : UWTOC, withChapter chapter : Int?, forArea area : TOCArea) {
        
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
                    strongself.selectTOC(results[0], withChapter : nil, forArea: area)
                    return
                }
            }
        
            // Fall through
            strongself.selectTOC(arrayTOCS[0], withChapter : nil, forArea: area)
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
                strongself.selectTOC(toc, withChapter: chapter, forArea: area)
            }
        }
        presentViewController(navVC, animated: true) { () -> Void in  }
    }
    
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
        
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        return nil
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 1
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 1
    }
    
    // Helpers
    
    func tocForArea(area : TOCArea) -> UWTOC? {
        switch area {
        case .Main:
            return tocMain
        case .Side:
            return tocSide
        }
        
    }
    
}