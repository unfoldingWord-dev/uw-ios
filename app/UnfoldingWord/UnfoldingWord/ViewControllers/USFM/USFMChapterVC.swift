//
//  USFMChapterVC.swift
//  UnfoldingWord
//
//  Created by David Solberg on 9/9/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

import Foundation

class USFMChapterVC : UIViewController, UITextViewDelegate {
    
    let MULTIPLIER_SHOWING_SIDE : CGFloat = 2
    let MULTIPLIER_HIDDEN_SIDE : CGFloat = 1
    
    var mainAttributes : AreaAttributes!
    var sideAttributes : AreaAttributes!

    var chapterNumber : Int! // It's a programming error if this isn't set before needed!

    var pointSize : CGFloat = 19
    
    private var isSideShowing : Bool {
        get {
            return constraintSideBySide.active
        }
    }
    
    private var isSettingUp = true
    
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var viewSideDiglot: UIView!
    
    @IBOutlet weak var textViewMain: UITextView!
    @IBOutlet weak var textViewSideDiglot: UITextView!
    
    @IBOutlet weak var buttonMain: UIButton!
    @IBOutlet weak var buttonSideDiglot: UIButton!
    
    @IBOutlet weak var labelEmptyMain: UILabel!
    @IBOutlet weak var labelEmptySide: UILabel!
    
    @IBOutlet var constraintSideBySide: NSLayoutConstraint!
    @IBOutlet var constraintMainOnly : NSLayoutConstraint!

    
    // Managing State across scrollviews - Is there a better way to do this?
    var lastMainOffset : CGPoint = CGPointZero
    var lastSideOffset : CGPoint = CGPointZero
    var countSetup : Int = 0
    
    weak var delegate : ChapterVCDelegate!
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadContentForArea(.Main, setToTop:true)
        loadContentForArea(.Side, setToTop:true)
        setSideViewToShowing(UFWSelectionTracker.isShowingSide(), animated: false)
    }
    
    override func viewWillAppear(animated: Bool) {
        textViewForArea(.Main).setContentOffset(CGPointZero, animated: false)
        textViewForArea(.Side).setContentOffset(CGPointZero, animated: false)

        super.viewWillAppear(animated)
        countSetup++
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        countSetup--
    }
    @IBAction func userPressedNextChapterButton(sender: AnyObject) {
        self.delegate.showNextTOC()
    }
    
    // Outside Methods
    func changePointSize(fontSize : CGFloat) {
        countSetup++
        pointSize = fontSize
        loadContentForArea(.Main, setToTop: false)
        loadContentForArea(.Side, setToTop: false)
        countSetup--
    }
    
    func loadContentForArea(area : TOCArea, setToTop isAtTop: Bool) {
        
        let attributes = attributesForArea(area)
        
        if let title = attributes.nextChapterText where attributes.isNextChapter {
            showNextChapterViewInArea(area, withTitle: title)
            return
        }
        else if attributes.isEmpty {
            showNothingLoadedViewInArea(area)
            return
        }
        else if let chapter = attributes.chapter, alignment = attributes.textAlignment {
            showChapter(chapter, withTextAlignment: alignment, inArea : area)
            
            if isAtTop {
                textViewForArea(area).setContentOffset(CGPointZero, animated: false)
            }
        }
        else {
            assertionFailure("Could not find an appropriate result for area \(area)")
        }
    }
    
    func showDiglotAnimated(animated : Bool) {
        loadContentForArea(.Side, setToTop:false)
        setSideViewToShowing(true, animated: animated)
    }
    
    func hideDiglotAnimated(animated : Bool) {
        setSideViewToShowing(false, animated: animated)
    }
    
    // Scrollview Delegate

    
    func isScrollMatchingNeeded() -> Bool {
        
        if isSideShowing == false || countSetup > 0 || sideAttributes.isNextChapter || sideAttributes.isEmpty {
            return false
        }
        else {
            return true
        }
    }
    
    var isScrollingContentDown = false
    var lastYOffset : CGFloat = 0
    var startingYOffset : CGFloat = 0
    var percentHidden : CGFloat = 0
    let scrollDistance : CGFloat  = 30
    
    func updateHiddenPercent(currentPercent : CGFloat) {
        
        var adjustedPercent = fmin(currentPercent, 1)
        adjustedPercent = fmax(adjustedPercent, 0)
        self.delegate.setTopBottomHiddenPercent(adjustedPercent)
        percentHidden = adjustedPercent
    }
    
    func updateVisibility(scrollView scrollView : UIScrollView) {
        
        let currentOffset = scrollView.contentOffset.y
        let distanceDraggedContentDown = currentOffset - startingYOffset
        isScrollingContentDown = (currentOffset - lastYOffset) > 0
        lastYOffset = currentOffset
        
        if percentHidden > 0 && currentOffset < 0 { // at the top
            let distanceAboveOrigin = -currentOffset
            let percentMovedAboveOrigin = distanceAboveOrigin / scrollDistance
            let changedPercentHidden = percentHidden - percentMovedAboveOrigin
            updateHiddenPercent(changedPercentHidden)
            scrollView.contentOffset.y = 0
            return
        }
        
        if abs(distanceDraggedContentDown) > scrollDistance && ( percentHidden <= 0 || percentHidden >= 1) {
            // if we're outside of bounds and not scrolling, then just stop
            return
        }
        
        // If we're actively scrolling the percent area and scrolling up, then update the percent showing
        else if distanceDraggedContentDown > 0 && percentHidden < 1 {
            updateHiddenPercent(abs(distanceDraggedContentDown) / scrollDistance )
            return
        }

    }
    
    func scrollViewDidScroll(scrollView: UIScrollView)
    {
        if countSetup == 0 {
            updateVisibility(scrollView: scrollView)
        }
        
        if isScrollMatchingNeeded() == false {
            return
        }
        
        let scrollingYDifference = scrollView.contentOffset.y - startingYOffset
        if scrollingYDifference < 50 && scrollingYDifference > 0 {
            // Okay, we might
        }
        
        
        if scrollView.isEqual(textViewMain) {
            let difference = textViewMain.contentOffset.y - lastMainOffset.y
            lastMainOffset = textViewMain.contentOffset
            adjustScrollView(textViewSideDiglot, byYPoints: difference)
        }
        else if scrollView.isEqual(textViewSideDiglot) {
            let difference = textViewSideDiglot.contentOffset.y - lastSideOffset.y
            lastSideOffset = textViewSideDiglot.contentOffset
            adjustScrollView(textViewMain, byYPoints: difference)
            
        }
        else {
            assertionFailure("The scrollview could not be identified \(scrollView)")
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if let textView = scrollView as? UITextView {
            handleTextViewDoneDragging(textView)
        }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if let textView = scrollView as? UITextView where decelerate == false {
            handleTextViewDoneDragging(textView)
        }
        if decelerate == true && isScrollingContentDown == false {
            self.delegate.animateTopBottomToShowing(true)
            percentHidden = 0
        }
    }
    
    func resetScrollViewTracking(scrollView scrollView : UIScrollView) {
        startingYOffset = scrollView.contentOffset.y
    }
    
    private func adjustScrollView(scrollView : UIScrollView, byYPoints difference : CGFloat) {
        countSetup++
        var changedOffset = scrollView.contentOffset
        changedOffset.y += difference
        changedOffset.y = fmax(changedOffset.y, 0)
        changedOffset.y = fmin(changedOffset.y, scrollView.contentSize.height - scrollView.frame.size.height)
        scrollView.contentOffset = changedOffset
        countSetup--
    }
    
    private func handleTextViewDoneDragging(textView : UITextView) {
        
        resetScrollViewTracking(scrollView: textView)
        
        if percentHidden > 0 && percentHidden < 1 {
            if percentHidden > 0.5 {
                self.delegate.animateTopBottomToShowing(false)
            }
            else {
                self.delegate.animateTopBottomToShowing(true)
            }
        }
        
        if isScrollMatchingNeeded() == false {
            return
        }
        
        guard let verseContainer = versesInTextView(textView) else {
            assertionFailure("Could not find verses in view \(textView)")
            return
        }
        
        if textView.isEqual(textViewSideDiglot) {
            adjustTextView(textViewMain, usingVerses: verseContainer, animated : true)
        }
        else if textView.isEqual(textViewMain) {
            adjustTextView(textViewSideDiglot, usingVerses: verseContainer, animated : true)
        }
        else {
            assertionFailure("The textview could not be identified \(textView)")
        }
    }
    
    private func adjustTextView(textView : UITextView, usingVerses verses : VerseContainer, animated: Bool) {

        countSetup++
        
        let attribText = textView.attributedText
        let verseToFind =  Bool(verses.maxIsAtEnd) ? verses.max : verses.min
        guard let firstY =  minYForVerseNumber(verseToFind, inAttributedString: attribText, inTextView: textView) else {
            assertionFailure("Could not find verse \(verseToFind) in \(textView)")
            return
        }
        var minY = firstY
        
        var relativeOffset : CGFloat = 0
        
        let yOriginOffset : CGFloat = verses.minRectRelativeToScreenPosition.origin.y
        let verseHeight : CGFloat = verses.minRectRelativeToScreenPosition.size.height
        
        let remoteVisiblePoints = verseHeight + yOriginOffset
        let remotePercentAboveOrigin = remoteVisiblePoints / verseHeight
        let percentBelowOrigin = 1 - remotePercentAboveOrigin
        
        var nextY : CGFloat
        if let candidate = minYForVerseNumber(verseToFind+1, inAttributedString: attribText, inTextView: textView) {
            nextY = candidate
        }
        else {
            nextY = minY
        }
        
        let distanceBetweenVerses = nextY - minY
        
        // 90 points is approximately a line or two. If we only have a couple of lines, then just match with the next verse, balanced by the percent showing across verses
        if remoteVisiblePoints < 90 && verseHeight > 90 {
            minY = nextY
            relativeOffset = remoteVisiblePoints * remotePercentAboveOrigin
        }
        else {
            // Trying to show relatively the same amount of verse for both sides. This is important because some verses are more than twice as long as their matching verses in another language or bible version.
            relativeOffset = -distanceBetweenVerses * percentBelowOrigin
        }
        
        // Adjust so the first visible verse starts in the same place on both screens.
        minY -= relativeOffset
        
        // Prevent the screen from scrolling past the end
        minY = fmin(minY, textView.contentSize.height - textView.frame.size.height)
        let offset = fabs( textView.contentOffset.y - minY)
        
        if offset > textView.frame.size.height {
            print("\(offset)")
//            assertionFailure("This should not happen")
        }
        
        textView.userInteractionEnabled = false
        textView.setContentOffset(CGPointMake(0, minY), animated: true)
        
        delay(0.5) { [weak self, weak textView] () -> Void in
            if let strongself = self, strongText = textView {
                strongself.countSetup--
                strongText.userInteractionEnabled = true
            }
        }
    }

    private func minYForVerseNumber(verseNumToFind : Int, inAttributedString attribString : NSAttributedString, inTextView textView : UITextView) -> CGFloat? {
        
        var minY : CGFloat = CGFloat.max
        textView.attributedText.enumerateAttributesInRange(NSMakeRange(0, textView.attributedText.length), options: []) { [weak self] (attributes : [String : AnyObject], rangeEnum, stop) -> Void in
            if let
                strongSelf = self,
                verse = attributes[Constants.USFM_VERSE_NUMBER] as? Int where verse == verseNumToFind,
                let locationRect = strongSelf.frameOfTextRange(rangeEnum, inTextView: textView)
            {
                minY = fmin(minY, locationRect.origin.y)
            }
        }
        return minY < CGFloat.max ? minY : nil
    }
    
    // Private
    
    private func showChapter(chapter : USFMChapter, withTextAlignment alignment : NSTextAlignment, inArea area : TOCArea) {
        let textView = textViewForArea(area)
        textView.attributedText = chapter.attributedStringWithSize(Double(pointSize));
        textView.textAlignment = alignment
        hideAllViewsExcept(textView, inArea: area)
    }
    
    private func showNextChapterViewInArea(area : TOCArea, withTitle title : String) {
        let button = buttonForArea(area)
        button.setTitle(title, forState: .Normal)
        hideAllViewsExcept(button, inArea: area)
    }
    
    private func showNothingLoadedViewInArea(area : TOCArea) {
        let label = labelForArea(area)
        label.text = NSLocalizedString("Choose a Bible Version from the top of the screen.", comment: "")
        hideAllViewsExcept(label, inArea: area)
    }
    
    // View Control
    
    private func setSideViewToShowing(isShowing : Bool, animated isAnimated : Bool) {
        
        if isShowing {
            constraintMainOnly.active = false
            constraintSideBySide.active = true
        }
        else {
            constraintSideBySide.active = false
            constraintMainOnly.active = true
        }
        
        if isAnimated {
            animateConstraintChanges()
        }
        else {
            self.view.layoutIfNeeded()
        }
    }
    
    private func hideAllViewsExcept(view : UIView, inArea area : TOCArea) {
        let label = labelForArea(area)
        let textView = textViewForArea(area)
        let button = buttonForArea(area)
        
        label.layer.opacity = label.isEqual(view) ? 1.0 : 0.0
        textView.layer.opacity = textView.isEqual(view) ? 1.0 : 0.0
        button.layer.opacity = button.isEqual(view) ? 1.0 : 0.0
    }

    
    // Matching Areas in Diglot View
    
    private func attributesForArea(area : TOCArea) -> AreaAttributes
    {
        switch area {
        case .Main:
            return mainAttributes
        case .Side:
            return sideAttributes
        }
    }
    
    private func textViewForArea(area : TOCArea) -> UITextView {
        switch area {
        case .Main:
            return textViewMain
        case .Side:
            return textViewSideDiglot
        }
    }
    
    private func buttonForArea(area : TOCArea) -> UIButton {
        switch area {
        case .Main:
            return buttonMain
        case .Side:
            return buttonSideDiglot
        }
    }
    
    private func labelForArea(area : TOCArea) -> UILabel {
        switch area {
        case .Main:
            return labelEmptyMain
        case .Side:
            return labelEmptySide
        }
    }
    
    // Matching Verses

    private func versesVisibleInArea(area : TOCArea) -> VerseContainer? {
        let textView = textViewForArea(area)
        return versesInTextView(textView)
    }
    
    private func visibleRangeOfTextView(textView : UITextView) -> NSRange? {
        
        var bounds = textView.frame
        bounds.origin = textView.contentOffset
        bounds.origin.y = fmax(bounds.origin.y, 0)
        bounds.size.height -= 30 // ignore the bottom range
        
        if let
            start : UITextPosition = textView.closestPositionToPoint(bounds.origin),
            end : UITextPosition = textView.closestPositionToPoint(CGPointMake(CGRectGetMaxX(bounds), CGRectGetMaxY(bounds))) {
                
                let location = textView.offsetFromPosition(textView.beginningOfDocument, toPosition: start)
                let length = textView.offsetFromPosition(textView.beginningOfDocument, toPosition: end) - location
                return NSMakeRange(location, length)
        }
        return nil
    }
    
    private func frameOfTextRange(range : NSRange, inTextView textView : UITextView) -> CGRect? {
        let previousSelection = textView.selectedRange
        defer {
            textView.selectedRange = previousSelection
        }
        
        textView.selectedRange = range
        if let textRange = textView.selectedTextRange {
            let frame = textView.firstRectForRange(textRange)
            textView.selectedRange = previousSelection
            return frame
        }
        else {
            assertionFailure("Could not create the range \(range) in the textview \(textView)")
            return nil
        }
    }
    
    func unadjustedFrameOfTextRange(range : NSRange, inTextView textView : UITextView) -> CGRect? {
        let previousSelection = textView.selectedRange
        defer {
            textView.selectedRange = previousSelection
        }
        
        textView.selectedRange = range
        guard let textRange = textView.selectedTextRange else {
            assertionFailure("Could not create the range \(range) in the textview \(textView)")
            return nil
        }
        
        var finalRect = CGRectZero
        let selectedRects = textView.selectionRectsForRange(textRange) as! [UITextSelectionRect]
        var isSetOnce = false
        
        for (_, textSelRect) in selectedRects.enumerate() {
            let foundRect = textSelRect.rect
            if isSetOnce == false {
                finalRect = foundRect
                isSetOnce = true
            }
            else {
                finalRect.origin.x = fmin(finalRect.origin.x, foundRect.origin.x)
                finalRect.origin.y = fmin(finalRect.origin.y, foundRect.origin.y)
                let height = CGRectGetMaxY(foundRect) - finalRect.origin.y
                finalRect.size.height = fmax(finalRect.size.height, height)
                finalRect.size.width = fmax(finalRect.size.width, foundRect.size.width)
            }
        }
        return finalRect
    }
    
    private func fullFrameOfVerseNumber(verseNumber : Int, inTextView textView : UITextView) -> CGRect {
        var frame = CGRectMake(CGFloat.max, CGFloat.max, 0, 0)
        
        textView.attributedText.enumerateAttributesInRange(NSMakeRange(0, textView.attributedText.length), options: []) { [weak self] (attributes : [String : AnyObject], rangeEnum, stop) -> Void in
            if let
                strongSelf = self,
                verse = attributes[Constants.USFM_VERSE_NUMBER] as? Int where verse == verseNumber,
                let unadjustedFrame = strongSelf.unadjustedFrameOfTextRange(rangeEnum, inTextView: textView)
            {
                frame.origin.x = fmin(frame.origin.x, unadjustedFrame.origin.x)
                frame.origin.y = fmin(frame.origin.y, unadjustedFrame.origin.y)
                let currentHeight = CGRectGetMaxY(unadjustedFrame) - frame.origin.y
                frame.size.height = fmax(frame.size.height, currentHeight)
                frame.size.width = fmax(frame.size.width, unadjustedFrame.size.width)
            }
        }
        
        frame.origin.y -= textView.contentOffset.y
        frame.origin.x -= textView.contentOffset.y
        
        assert(frame.origin.x != CGFloat.max && frame.origin.y != CGFloat.max, "The frame was not set for verse \(verseNumber) in textview \(textView)")
        
        return frame
    }
    
    private func versesInTextView(textView: UITextView) -> VerseContainer? {

        guard let visibleRange = visibleRangeOfTextView(textView) else {
            assertionFailure("Could not find a visible range in textview \(textView)")
            return nil
        }
        let textInRange = textView.attributedText.attributedSubstringFromRange(visibleRange)
        
        var rowHeight : Float = 0
        var minVerse : Int = NSInteger.max
        var maxVerse : Int = 0
        var minRelativeRect = CGRectZero
        var maxRelativeRect = CGRectZero
        var minIsAtStart = false
        var maxIsAtEnd = false
        
        textInRange.enumerateAttributesInRange(NSMakeRange(0, textInRange.length), options: []) { [weak self] (attributes : [String : AnyObject], rangeEnum, stop) -> Void in
            if let
                strongself = self,
                number = attributes[Constants.USFM_VERSE_NUMBER] as? Int,
                frame = strongself.frameOfTextRange(rangeEnum, inTextView: textView)
            {
                rowHeight = fmaxf(rowHeight, Float(frame.size.height))
                if minVerse >= number && frame.size.width > 15 && rangeEnum.length > 5 { // the 5 is to catch newlines and other trailing characters
                    minRelativeRect = strongself.fullFrameOfVerseNumber(number, inTextView: textView)
                    if textView.contentOffset.y < 5 { // 5 = wiggle room
                        minIsAtStart = true
                    }
                    minVerse = number
                }
                if maxVerse < number || maxVerse == number {
                    maxVerse = number
                    maxRelativeRect = strongself.fullFrameOfVerseNumber(number, inTextView: textView)
                    if (textView.contentOffset.y + textView.frame.size.height) >= (textView.contentSize.height - 10) {
                        maxIsAtEnd = true
                    }
                }
            }
        }
        
        if minVerse == NSInteger.max {
            assertionFailure("No verses were found in textview \(textView)")
            return nil
        }
        
        var container = VerseContainer()
        container.min = minVerse
        container.max = maxVerse
        container.minIsAtStart = ObjCBool.init(minIsAtStart)
        container.maxIsAtEnd = ObjCBool.init( maxIsAtEnd)
        container.minRectRelativeToScreenPosition = minRelativeRect
        container.maxRectRelativeToScreenPosition = maxRelativeRect
        container.rowHeight = CGFloat(rowHeight)
        return container
    }
}
