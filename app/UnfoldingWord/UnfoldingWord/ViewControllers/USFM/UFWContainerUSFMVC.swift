//
//  UFWContainerUSFMVC.swift
//  UnfoldingWord
//
//  Created by David Solberg on 7/20/15.
//

import UIKit

@objc protocol USFMPanelDelegate {
    // These methods make sure that both views are equivalent -- trampolines for user interactions.
    func userDidScroll(vc : UFWTextChapterVC, verticalOffset : CGFloat)
    func userDidScroll(vc : UFWTextChapterVC, horizontalOffset: CGFloat)
    func userFinishedScrolling(vc : UFWTextChapterVC, verses : VerseContainer)
    func userFinishedScrollingCollectionView(vc : UFWTextChapterVC)
    
    
    func userChangedTOC(vc : UFWTextChapterVC, pickedTOC : UWTOC)
    func matchingVCVerses(vc : UFWTextChapterVC) -> VerseContainer

    // Information to help rotation and sizing events.
    func expectedContainerWidthAfterRotation() -> CGFloat
}

final class UFWContainerUSFMVC: UIViewController, USFMPanelDelegate, ACTLabelButtonDelegate {
    
    @IBOutlet weak var viewMain : UIView!
    @IBOutlet weak var viewSide : UIView!
    
    @IBOutlet weak var constraintSideViewToRightEdge : NSLayoutConstraint!
    @IBOutlet weak var constraintMainViewToRightEdge : NSLayoutConstraint!
    @IBOutlet weak var constraintSpacerWidth : NSLayoutConstraint!
    
    @objc var topContainer : UWTopContainer! // Must be assigned before view loads!
    
    let vcMain : UFWTextChapterVC
    let vcSide : UFWTextChapterVC
    
    var initialLoadComplete : Bool = false
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        self.vcMain = UFWContainerUSFMVC.createTextChapterVC()
        self.vcMain.isSideTOC = false;
        self.vcSide = UFWContainerUSFMVC.createTextChapterVC()
        self.vcSide.isSideTOC = true;
        self.topContainer = nil // Must be assigned before view loads!
        
        super.init(nibName: nibNameOrNil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.vcMain = UFWContainerUSFMVC.createTextChapterVC()
        self.vcMain.isSideTOC = false;
        self.vcSide = UFWContainerUSFMVC.createTextChapterVC()
        self.vcSide.isSideTOC = true;
        self.topContainer = nil // Must be assigned before view loads!

        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.vcMain.topContainer = self.topContainer
        self.vcSide.topContainer = self.topContainer
        
        self.viewMain.backgroundColor = .white
        self.viewSide.backgroundColor = .white
        
        addChildViewController(childVC: self.vcMain, toView: self.viewMain)
        addChildViewController(childVC: self.vcSide, toView: self.viewSide)
        
        updateNavChapterButton()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: Constants.Image_Diglot), style: .plain, target: self, action: Selector("toggleSideBySideView"))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if initialLoadComplete == false {
            arrangeViews(startDark: true)
            initialLoadComplete = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.vcMain.delegate = self
        self.vcSide.delegate = self
    }
    
    // User Interaction - Open and Close 
    
    func toggleSideBySideView() {
        self.vcSide.isActive = !self.vcSide.isActive
        arrangeViews(startDark: false)
    }
    
    /// The animates the views into place. It really isn't working well right now, but the problems are hidden with fades.
    func arrangeViews(startDark : Bool) {
        
        let verses = self.vcMain.versesVisible()
        let initialLocationMain = self.vcMain.currentTextLocation()
        let initialLocationSide = self.vcSide.currentTextLocation()
        
        self.vcMain.willSetup()
        self.vcSide.willSetup()
        
        let coverView = UIView(frame: self.view.bounds);
        coverView.backgroundColor = .black
        coverView.layer.opacity = startDark ? 1.0 : 0.0
        self.view.addSubview(coverView)

        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn) {
            coverView.layer.opacity = 1.0;

        } completion: { completed in
            let required = UILayoutPriority(rawValue: 999)
            let basicallyNothing = UILayoutPriority(rawValue: 1)

            if self.vcSide.isActive {
                self.constraintMainViewToRightEdge.priority = basicallyNothing
                self.constraintSideViewToRightEdge.priority = required
            } else {
                self.constraintMainViewToRightEdge.priority = required
                self.constraintSideViewToRightEdge.priority = basicallyNothing
            }

            self.vcSide.view.setNeedsUpdateConstraints()
            self.vcMain.view.setNeedsUpdateConstraints()


            self.view.layoutIfNeeded()
            self.vcMain.view.layoutIfNeeded()
            self.vcSide.view.layoutIfNeeded()

            self.vcMain.change(to: .zero)
            self.vcSide.change(to: .zero)

            self.vcMain.updateVersionTitle()
            self.vcSide.updateVersionTitle()


            self.vcSide.didSetup()
            self.vcMain.didSetup()

            UIView.animate(withDuration: 0.25, delay: 0.15, options: .curveEaseInOut) {
                coverView.layer.opacity = 0.0;
                self.vcMain.adjustTextView(withVerses: verses, animationDuration: 0.0)
                self.vcSide.adjustTextView(withVerses: verses, animationDuration: 0.0)
                self.vcMain.scroll(toLocation: initialLocationMain, animated: false)
                self.vcSide.scroll(toLocation: initialLocationSide, animated: false)
            } completion: { comple in
                coverView.removeFromSuperview()
            }
        }
    }
    
    // Delegate Methods - Trampolines
    func userDidScroll(vc : UFWTextChapterVC, verticalOffset : CGFloat)
    {
        if let matchingVC = matchingViewController(vc: vc) {
            matchingVC.scrollTextView(verticalOffset)
        }
    }
    
    func userDidScroll(vc : UFWTextChapterVC, horizontalOffset: CGFloat)
    {
        if let matchingVC = matchingViewController(vc: vc) {
            matchingVC.scrollCollectionView(horizontalOffset)
        }
    }
    
    func userFinishedScrolling(vc : UFWTextChapterVC, verses : VerseContainer)
    {
        if let matchingVC = matchingViewController(vc: vc) {
            matchingVC.adjustTextView(withVerses: verses, animationDuration: 1.0);
        }
    }
    
    func userChangedTOC(vc : UFWTextChapterVC, pickedTOC : UWTOC)
    {
        if let matchingVC = matchingViewController(vc: vc) {
            matchingVC.changeTo(matching: pickedTOC)
        }
        updateNavChapterButton()
    }
    
    func userFinishedScrollingCollectionView(vc : UFWTextChapterVC)
    {
        if let matchingVC = matchingViewController(vc: vc) {
            matchingVC.matchingCollectionViewDidFinishScrolling()
        }
        updateNavChapterButton()
    }
    
    func expectedContainerWidthAfterRotation() -> CGFloat
    {
        let height = windowHeight()
        if self.vcSide.isActive {
            let availableSpace = height - self.constraintSpacerWidth.constant
            return availableSpace / 2.0
        }
        else {
            return height
        }
    }
    
    func matchingVCVerses(vc : UFWTextChapterVC) -> VerseContainer
    {
        if let matchingVC = matchingViewController(vc: vc) {
            return matchingVC.versesVisible()
        }
        else {
            return VerseContainer(min: 1, minRectRelativeToScreenPosition: .zero, minIsAtStart: true, max: 1, maxRectRelativeToScreenPosition: .zero, maxIsAtEnd: false, rowHeight: 10)
        }
    }
    
    func updateNavChapterButton()
    {
        let button = ACTLabelButton(frame: CGRect(x: 0, y: 0, width: 110, height: 30))

        if let toc = UFWSelectionTracker.toCforUSFM() {
            button.text = "\(toc.title ?? "") \(UFWSelectionTracker.chapterNumberUSFM())"
        }
        else {
            button.text = "Select Book"
        }

        button.font = UIFont(name: "HelveticaNeue-Medium", size: 17)

        if let text = button.text, let font = button.font {
            button.frame = CGRect(x: 0, y: 0, width: text.width(using: font) + ACTLabelButton.widthForArrow(), height: 38);
        }
        
        button.delegate = self
        button.direction = ArrowDirection.down
        button.colorHover = UIColor.lightGray
        button.colorNormal = UIColor.white
        button.isUserInteractionEnabled = true
        
        self.navigationItem.titleView = button
    }
    
    func labelButtonPressed(_ labelButton : ACTLabelButton) {
        self.vcMain.bookButtonPressed()
    }

    func windowHeight() -> CGFloat
    {
        let windowFrame = UIScreen.main.bounds
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
        if vc == self.vcMain {
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
