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
    
}