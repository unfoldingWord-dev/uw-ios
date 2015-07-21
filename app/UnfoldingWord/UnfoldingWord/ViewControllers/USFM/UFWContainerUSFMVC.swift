//
//  UFWContainerUSFMVC.swift
//  UnfoldingWord
//
//  Created by David Solberg on 7/20/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

import UIKit

protocol USFMPanelDelegate {
    func userDidScroll(#vc : UFWTextChapterVC, verticalOffset : Float)
    func userDidScroll(#vc : UFWTextChapterVC, horizontalOffset: Float)
    func userFinishedScrolling(#vc : UFWTextChapterVC, startVerse : Int, endVerse : Int)
    func userChangedTOC(#vc : UFWTextChapterVC, pickedTOC : UWTOC)
}

class UFWContainerUSFMVC: UIViewController {
    
    @IBOutlet weak var viewMain : UIView!
    @IBOutlet weak var viewSide : UIView!
    
    @IBOutlet weak var constraintSideViewToRightEdge : NSLayoutConstraint!
    @IBOutlet weak var constraintMainViewToRightEdge : NSLayoutConstraint!
    
    var topContainer : UWTopContainer! // Must be assigned before view loads!
    
    let vcMain : UFWTextChapterVC
    let vcSide : UFWTextChapterVC
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        self.vcMain = UFWContainerUSFMVC.createTextChapterVC()
        self.vcSide = UFWContainerUSFMVC.createTextChapterVC()
        self.topContainer = nil // Must be assigned before view loads!
    
        super.init(nibName: nibNameOrNil, bundle: nil)
    }
    
    func scrollHorizontally(offset : Float) {
        
    }
    
    func scrollVertically(offset : Float) {
        
    }
    
    func recenterWithStartVerse(startVerse : Int, endVerse : Int) {
        
    }
    
    func changeToMatchTOC(toc : UWTOC) {
        
    }
    
    required init(coder aDecoder: NSCoder) {
        self.vcMain = UFWContainerUSFMVC.createTextChapterVC()
        self.vcSide = UFWContainerUSFMVC.createTextChapterVC()
        self.topContainer = nil // Must be assigned before view loads!
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.vcMain.topContainer = self.topContainer
        self.vcSide.topContainer = self.topContainer
        
        self.vcMain.isSideTOC = false
        self.vcSide.isSideTOC = true
                
        self.addChildViewController(self.vcMain, toView: self.viewMain)
        self.addChildViewController(self.vcSide, toView: self.viewSide)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        arrangeViews(animated: false)
    }
    
    func arrangeViews(#animated : Bool) {
        
        if let aTOCForSide = UFWSelectionTracker.TOCforUSFMSide() {
            self.constraintMainViewToRightEdge.priority = UILayoutPriorityDefaultLow
            self.constraintSideViewToRightEdge.priority = UILayoutPriorityRequired
        } else {
            self.constraintMainViewToRightEdge.priority = UILayoutPriorityRequired
            self.constraintSideViewToRightEdge.priority = UILayoutPriorityDefaultLow
        }
        
        let duration = animated ? 0.5 : 0.0
        UIView.animateWithDuration(duration, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }

    
    // Helpers
    
    class func createTextChapterVC() -> UFWTextChapterVC {
        return self.getStoryboard().instantiateInitialViewController() as! UFWTextChapterVC
    }
    
    class func getStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "USFM", bundle: nil)
    }
}
