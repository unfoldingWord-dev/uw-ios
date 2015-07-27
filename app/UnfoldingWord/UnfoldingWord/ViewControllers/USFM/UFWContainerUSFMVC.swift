//
//  UFWContainerUSFMVC.swift
//  UnfoldingWord
//
//  Created by David Solberg on 7/20/15.
//

import UIKit

@objc protocol USFMPanelDelegate {
    // These methods make sure that both views are equivalent -- trampolines for user interactions.
    func userDidScroll(#vc : UFWTextChapterVC, verticalOffset : CGFloat)
    func userDidScroll(#vc : UFWTextChapterVC, horizontalOffset: CGFloat)
    func userFinishedScrolling(#vc : UFWTextChapterVC, verses : VerseContainer)
    func userFinishedScrollingCollectionView(#vc : UFWTextChapterVC)
    func userChangedTOC(#vc : UFWTextChapterVC, pickedTOC : UWTOC)
//
//    // These are information to help rotation and sizing events.
    func containerSize() -> CGSize
    func containerSizeRotated() -> CGSize
}

class UFWContainerUSFMVC: UIViewController, USFMPanelDelegate, ACTLabelButtonDelegate {
    
    @IBOutlet weak var viewMain : UIView!
    @IBOutlet weak var viewSide : UIView!
    
    @IBOutlet weak var constraintSideViewToRightEdge : NSLayoutConstraint!
    @IBOutlet weak var constraintMainViewToRightEdge : NSLayoutConstraint!
    @IBOutlet weak var constraintSpacerWidth : NSLayoutConstraint!
    
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
        
        self.navigationItem.titleView = navChapterButton(UFWSelectionTracker.TOCforUSFM())
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Side", style: UIBarButtonItemStyle.Plain, target: self, action: "toggleSideBySideView")
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
        self.navigationItem.titleView = navChapterButton(UFWSelectionTracker.TOCforUSFM())
    }
    
    func userFinishedScrollingCollectionView(#vc : UFWTextChapterVC)
    {
        
    }
    
    func containerSize() -> CGSize
    {
        return self.viewMain.frame.size
    }
    
    func containerSizeRotated() -> CGSize
    {
        
        // Get height of status bar - either 44 or 36
        return CGSizeZero
    }
    
    func navChapterButton(toc : UWTOC?) -> ACTLabelButton
    {
        let button = ACTLabelButton(frame: CGRectMake(0, 0, 110, 30))

        if let toc = toc {
            button.text = "\(toc.title) \(UFWSelectionTracker.chapterNumberUSFM())"
        }
        else {
            button.text = "Select Book"
        }
        
        if let text = button.text, font = button.font {
            button.frame = CGRectMake(0, 0, text.widthUsingFont(font) + ACTLabelButton.widthForArrow(), 38);
        }
        
        button.font = UIFont(name: "HelveticaNeue-Medium", size: 17)
        button.delegate = self
        button.direction = ArrowDirection.Down
        button.colorHover = UIColor.lightGrayColor()
        button.colorNormal = UIColor.whiteColor()
        button.userInteractionEnabled = true
        
        return button
    }
    func labelButtonPressed(labelButton : ACTLabelButton) {
        self.vcMain.bookButtonPressed()
    }

    func windowHeight() -> CGFloat
    {
        let windowFrame = UIScreen.mainScreen().bounds
        var height : CGFloat = 0
        if self.view.bounds.size.width > self.view.bounds.size.height {
            height = min(windowFrame.size.height, windowFrame.size.width)
        }
        else {
            height = max(windowFrame.size.height, windowFrame.size.width)
        }
        return height
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
