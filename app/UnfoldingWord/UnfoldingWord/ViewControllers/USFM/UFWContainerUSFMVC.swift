//
//  UFWContainerUSFMVC.swift
//  UnfoldingWord
//
//  Created by David Solberg on 7/20/15.
//

import UIKit

// These methods make sure that both views are equivalent -- trampolines for user interactions.
@objc protocol USFMPanelDelegate {
    func userDidScroll(#vc : UFWTextChapterVC, verticalOffset : CGFloat)
    func userDidScroll(#vc : UFWTextChapterVC, horizontalOffset: CGFloat)
    func userFinishedScrolling(#vc : UFWTextChapterVC, verses : VerseContainer)
    func userChangedTOC(#vc : UFWTextChapterVC, pickedTOC : UWTOC)
}

class UFWContainerUSFMVC: UIViewController, USFMPanelDelegate {
    
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
    
    required init(coder aDecoder: NSCoder) {
        self.vcMain = UFWContainerUSFMVC.createTextChapterVC()
        self.vcSide = UFWContainerUSFMVC.createTextChapterVC()
        self.topContainer = nil // Must be assigned before view loads!
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.vcMain.isSideTOC = false
        self.vcSide.isSideTOC = true
        
        self.vcMain.topContainer = self.topContainer
        self.vcSide.topContainer = self.topContainer
        
        addChildViewController(self.vcMain, toView: self.viewMain)
        addChildViewController(self.vcSide, toView: self.viewSide)
        
        self.vcMain.delegate = self
        self.vcSide.delegate = self
        
        self.navigationItem.title = self.topContainer.title
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Side", style: UIBarButtonItemStyle.Plain, target: self, action: "toggleSideBySideView")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        arrangeViews(animated: false)
    }
    
    // User Interaction - Open and Close 
    
    @IBAction func toggleSideBySideView() {
        self.vcSide.isActive = !self.vcSide.isActive
        arrangeViews(animated: true)
    }
    
    func arrangeViews(#animated : Bool) {
        
        let required : UILayoutPriority = 999
        let basicallyNothing : UILayoutPriority = 1
        
        if self.vcSide.isActive {
            self.constraintMainViewToRightEdge.priority = basicallyNothing
            self.constraintSideViewToRightEdge.priority = required
        } else {
            self.constraintMainViewToRightEdge.priority = required
            self.constraintSideViewToRightEdge.priority = basicallyNothing
        }
        
        self.vcSide.view.setNeedsUpdateConstraints()
        self.vcMain.view.setNeedsUpdateConstraints()
        
        let duration = animated ? 0.5 : 0.0
        
        UIView.animateWithDuration(duration, animations: { () -> Void in
            self.view.layoutIfNeeded()
            self.vcMain.view.layoutIfNeeded()
            self.vcSide.view.layoutIfNeeded()
        }) { (complete) -> Void in
            self.vcMain.changeToSize(CGSizeZero)
            self.vcSide.changeToSize(CGSizeZero)
        }
    }
    
    // Delegate Methods - Trampolines
    func userDidScroll(#vc : UFWTextChapterVC, verticalOffset : CGFloat)
    {
        if let matchingVC = matchingViewController(vc) {
            matchingVC.scrollTextView(verticalOffset)
        }
    }
    
    func userDidScroll(#vc : UFWTextChapterVC, horizontalOffset: CGFloat)
    {
        if let matchingVC = matchingViewController(vc) {
            matchingVC.scrollCollectionView(horizontalOffset)
        }
    }
    
    func userFinishedScrolling(#vc : UFWTextChapterVC, verses : VerseContainer)
    {
        if let matchingVC = matchingViewController(vc) {
            matchingVC.adjustTextViewWithVerses(verses)
        }
    }
    
    func userChangedTOC(#vc : UFWTextChapterVC, pickedTOC : UWTOC)
    {
        if let matchingVC = matchingViewController(vc) {
            matchingVC.changeToMatchingTOC(pickedTOC)
        }
    }
    
    // Helpers
    class func createTextChapterVC() -> UFWTextChapterVC {
        return self.getStoryboard().instantiateInitialViewController() as! UFWTextChapterVC
    }
    
    class func getStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "USFM", bundle: nil)
    }
    
    func matchingViewController(vc : UFWTextChapterVC) -> UFWTextChapterVC?
    {
        if self.vcSide.isActive  == false {
            return nil
        }
        else if vc == self.vcMain {
            return self.vcSide
        }
        else if vc == self.vcSide {
            return self.vcMain
        }
        else {
            return nil
        }
    }
}
