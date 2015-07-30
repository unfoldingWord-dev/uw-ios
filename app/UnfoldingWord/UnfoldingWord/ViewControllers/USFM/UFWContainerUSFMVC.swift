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

//    // These are information to help rotation and sizing events.
    func expectedContainerWidthAfterRotation() -> CGFloat
}

class UFWContainerUSFMVC: UIViewController, USFMPanelDelegate, ACTLabelButtonDelegate {
    
    @IBOutlet weak var viewMain : UIView!
    @IBOutlet weak var viewSide : UIView!
    
    @IBOutlet weak var constraintSideViewToRightEdge : NSLayoutConstraint!
    @IBOutlet weak var constraintMainViewToRightEdge : NSLayoutConstraint!
    @IBOutlet weak var constraintSpacerWidth : NSLayoutConstraint!
    
    var isScrollingCollectionView: Bool
    
    var topContainer : UWTopContainer! // Must be assigned before view loads!
    
    let vcMain : UFWTextChapterVC
    let vcSide : UFWTextChapterVC
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        self.vcMain = UFWContainerUSFMVC.createTextChapterVC()
        self.vcSide = UFWContainerUSFMVC.createTextChapterVC()
        self.topContainer = nil // Must be assigned before view loads!
        self.isScrollingCollectionView = false
        super.init(nibName: nibNameOrNil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        self.vcMain = UFWContainerUSFMVC.createTextChapterVC()
        self.vcSide = UFWContainerUSFMVC.createTextChapterVC()
        self.topContainer = nil // Must be assigned before view loads!
        self.isScrollingCollectionView = false

        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.vcMain.isSideTOC = false
        self.vcSide.isSideTOC = true
        
        self.vcMain.topContainer = self.topContainer
        self.vcSide.topContainer = self.topContainer
        
        self.viewMain.backgroundColor = UIColor.whiteColor()
        self.viewSide.backgroundColor = UIColor.whiteColor()
        
        addChildViewController(self.vcMain, toView: self.viewMain)
        addChildViewController(self.vcSide, toView: self.viewSide)
        
        updateNavChapterButton()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Side", style: UIBarButtonItemStyle.Plain, target: self, action: "toggleSideBySideView")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        arrangeViews(startDark: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.vcMain.delegate = self
        self.vcSide.delegate = self
    }
    
    // User Interaction - Open and Close 
    
    @IBAction func toggleSideBySideView() {
        self.vcSide.isActive = !self.vcSide.isActive
        arrangeViews(startDark: false)
    }
    
    func arrangeViews(#startDark : Bool) {
        
        let verses1 = self.vcMain.versesVisible()
        
        self.vcMain.willSetup()
        self.vcSide.willSetup()
        
        let coverView = UIView(frame: self.view.bounds);
        coverView.backgroundColor = UIColor.blackColor()
        coverView.layer.opacity = startDark ? 1.0 : 0.0
        self.view.addSubview(coverView)
        
        [UIView .animateWithDuration(0.25, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            coverView.layer.opacity = 1.0;
        }, completion: { (completed) -> Void in
            
            let verses = self.vcMain.versesVisible()
            
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
            
            let mainPosition = self.vcMain.currentTextLocation()
            
            self.view.layoutIfNeeded()
            self.vcMain.view.layoutIfNeeded()
            self.vcSide.view.layoutIfNeeded()
            
            self.vcMain.changeToSize(CGSizeZero)
            self.vcSide.changeToSize(CGSizeZero)
            
            self.vcMain.updateVersionTitle()
            
            self.vcSide.updateVersionTitle()
            
            self.vcSide.didSetup()
            self.vcMain.didSetup()

            [UIView .animateWithDuration(0.25, delay: 0.15, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                coverView.layer.opacity = 0.0;
                
            }, completion: { (completed) -> Void in
                coverView.removeFromSuperview()
                self.vcMain.adjustTextViewWithVerses(verses)
                self.vcSide.adjustTextViewWithVerses(verses)

            })]
        })]

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
        updateNavChapterButton()
    }
    
    func userFinishedScrollingCollectionView(#vc : UFWTextChapterVC)
    {
        if let matchingVC = matchingViewController(vc) {
            matchingVC.matchingCollectionViewDidFinishScrolling()
        }
        updateNavChapterButton()
    }
    
    func expectedContainerWidthAfterRotation() -> CGFloat
    {
        let height = windowHeight()
        if self.vcSide.isActive {
            var availableSpace = height - self.constraintSpacerWidth.constant
            return availableSpace / 2.0
        }
        else {
            return height
        }
    }
    
    func updateNavChapterButton()
    {
        let button = ACTLabelButton(frame: CGRectMake(0, 0, 110, 30))

        if let toc = UFWSelectionTracker.TOCforUSFM() {
            button.text = "\(toc.title) \(UFWSelectionTracker.chapterNumberUSFM())"
        }
        else {
            button.text = "Select Book"
        }
        
        button.font = UIFont(name: "HelveticaNeue-Medium", size: 17)

        if let text = button.text, font = button.font {
            button.frame = CGRectMake(0, 0, text.widthUsingFont(font) + ACTLabelButton.widthForArrow(), 38);
        }
        
        button.delegate = self
        button.direction = ArrowDirection.Down
        button.colorHover = UIColor.lightGrayColor()
        button.colorNormal = UIColor.whiteColor()
        button.userInteractionEnabled = true
        
        self.navigationItem.titleView = button
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

//
//
///// animated version when I have time
//
//func arrangeViews(#animated : Bool) {
//    
//    let required : UILayoutPriority = 999
//    let basicallyNothing : UILayoutPriority = 1
//    
//    if self.vcSide.isActive {
//        self.constraintMainViewToRightEdge.priority = basicallyNothing
//        self.constraintSideViewToRightEdge.priority = required
//    } else {
//        self.constraintMainViewToRightEdge.priority = required
//        self.constraintSideViewToRightEdge.priority = basicallyNothing
//    }
//    
//    let duration = animated ? 0.0 : 0.0
//    
//    
//    self.vcSide.view.setNeedsUpdateConstraints()
//    self.vcMain.view.setNeedsUpdateConstraints()
//    
//    self.vcMain.willSetup()
//    self.vcSide.willSetup()
//    
//    let mainPosition = self.vcMain.currentTextLocation()
//    
//    UIView.animateWithDuration(duration, animations: { () -> Void in
//        self.view.layoutIfNeeded()
//        
//        self.vcMain.view.layoutIfNeeded()
//        self.vcSide.view.layoutIfNeeded()
//        
//        self.vcMain.scrollToLocation(mainPosition, animated: false)
//        
//        
//        }) { (complete) -> Void in
//            
//            self.vcMain.updateVersionTitle()
//            self.vcMain.changeToSize(CGSizeZero)
//            self.vcMain.scrollToLocation(mainPosition, animated: false)
//            
//            self.vcSide.changeToSize(CGSizeZero)
//            self.vcSide.updateVersionTitle()
//            self.vcSide.adjustTextViewWithVerses(self.vcMain.versesVisible())
//            
//            self.vcSide.didSetup()
//            self.vcMain.didSetup()
//    }
//}
