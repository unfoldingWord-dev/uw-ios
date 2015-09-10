//
//  USFMChapterVC.swift
//  UnfoldingWord
//
//  Created by David Solberg on 9/9/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

import Foundation

enum TOCArea {
    case Main
    case Side
}

class USFMChapterVC : UIViewController, UITextViewDelegate {
    
    var tocMain : UWTOC? = nil {
        didSet {
            arrayMainChapters = chaptersFromTOC(tocMain)
        }
    }
    var tocSide : UWTOC? = nil {
        didSet {
            arrayMainChapters = chaptersFromTOC(tocSide)
        }
    }
    var arrayMainChapters: [USFMChapter]? = nil
    var arraySideChapters: [USFMChapter]? = nil
    
    var chapterNumber : Int! { // It's a programming error if this isn't set before needed!
        didSet {
            assert(chapterNumber > 0, "The chapter number \(chapterNumber) must be greater than zero!")
        }
    }
    
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var viewSideDiglot: UIView!
    
    @IBOutlet weak var textViewMain: UITextView!
    @IBOutlet weak var textViewSideDiglot: UITextView!
    
    @IBOutlet weak var buttonMain: UIButton!
    @IBOutlet weak var buttonSideDiglot: UIButton!
    
    @IBOutlet weak var labelEmptyMain: UILabel!
    @IBOutlet weak var labelEmptySide: UILabel!
    
    @IBOutlet weak var constraintMainViewProportion: NSLayoutConstraint!
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadContentForArea(.Main)
        if tocSide != nil {
            setSideViewToShowing(true, animated: false)
            loadContentForArea(.Side)
        }
    }
    
    // Outside Methods
    func showDiglotWithToc(toc : UWTOC) {
        tocSide = toc
        loadContentForArea(.Side)
        setSideViewToShowing(true, animated: true)
    }
    
    func hideDiglot() {
        tocSide = nil
        setSideViewToShowing(false, animated: true)
    }
    
    
    
    
    
    // Private
    
    private func loadContentForArea(area : TOCArea) {
        
        guard let chapters = chaptersForArea(area) else {
            showNothingLoadedViewInArea(area)
            return
        }
        
        guard chapterNumber >= chapters.count else {
            showNextChapterViewInArea(area)
            return
        }
        
        guard let toc = tocForArea(area) else {
            assertionFailure("We have chapters for area \(area) but no TOC. That shouldn't be possible.")
            showNothingLoadedViewInArea(area)
            return
        }
        
        // Okay, everything's good, so show the chapter in the textview
        let chapter : USFMChapter = chapters[chapterNumber]
        showChapter(chapter, withTOC: toc, inArea: area)
    }
    
    private func showChapter(chapter : USFMChapter, withTOC toc: UWTOC, inArea area : TOCArea) {
        let textView = textViewForArea(area)
        textView.textAlignment = LanguageInfoController.textAlignmentForLanguageCode(toc.version.language.lc)
        textView.attributedText = chapter.attributedString;
        hideAllViewsExcept(textView, inArea: area)
    }
    
    private func showNextChapterViewInArea(area : TOCArea) {
        let button = buttonForArea(area)
        if let toc = tocForArea(area) {
            let goto = NSLocalizedString("Go to", comment: "Name of bible chapter goes after this text")
            let buttonTitle = "\(goto) \(toc.title)"
            button.setTitle(buttonTitle, forState: .Normal)
        }
        else {
            assertionFailure("Could not find a toc. No sense in having a next chapter button")
        }
        hideAllViewsExcept(button, inArea: area)
    }
    
    private func showNothingLoadedViewInArea(area : TOCArea) {
        let label = labelForArea(area)
        label.text = NSLocalizedString("Choose a Bible Version from the top of the screen.", comment: "")
        hideAllViewsExcept(label, inArea: area)
    }
    
    // View Control
    
    private func setSideViewToShowing(isShowing : Bool, animated isAnimated : Bool) {
        constraintMainViewProportion.constant = isShowing ? 2 : 1
        self.view.setNeedsUpdateConstraints()
        if isAnimated == false {
            self.view.layoutIfNeeded()
        }
        else {
            UIView.animateWithDuration(0.25, delay: 0.0, usingSpringWithDamping: 0.85, initialSpringVelocity: 1.2, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                self.view.layoutIfNeeded()
                }, completion: { (completed) -> Void in
                    
            })
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
    
    // Helpers for TOC Items
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
    
    // Matching Areas in Diglot View
    private func chaptersForArea(area : TOCArea) -> [USFMChapter]? {
        switch area {
        case .Main:
            return arrayMainChapters
        case .Side:
            return arraySideChapters
        }
    }
    
    private func tocForArea(area : TOCArea) -> UWTOC? {
        switch area {
        case .Main:
            return tocMain
        case .Side:
            return tocSide
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
    
    // Helpers
    
    private func chaptersFromTOC(toc : UWTOC?) -> [USFMChapter]? {
        if let toc = toc, chapters = toc.usfmInfo.chapters() as? [USFMChapter] {
            return chapters
        }
        else {
            return nil
        }
    }
    
    // Matching Verses

//    - (VerseContainer)versesVisible
//    {
//    USFMChapterCell *cell = [self visibleChapterCell];
//    return  [self versesInTextView:cell.textView];
//    }
//    
    
    private func visibleRangeOfTextView(textView : UITextView) -> NSRange? {
        
        var bounds = textView.frame
        bounds.origin = textView.contentOffset
        bounds.size.height -= 30 // ignore the bottom range
        
        if let
            start : UITextPosition = textView.characterRangeAtPoint(bounds.origin)?.start,
            end : UITextPosition = textView.characterRangeAtPoint(CGPointMake(CGRectGetMaxX(bounds), CGRectGetMaxY(bounds)))?.end {
                
                let location = textView.offsetFromPosition(textView.beginningOfDocument, toPosition: start)
                let length = textView.offsetFromPosition(textView.beginningOfDocument, toPosition: end) - location
                return NSMakeRange(location, length)
        }
        return nil
    }
    
    
    private func versesInTextView(textView: UITextView) -> VerseContainer {
        var container = VerseContainer()
        container.min = 1
        container.max = 1
        container.minIsAtStart = false
        container.maxIsAtEnd = false
        container.maxRectRelativeToScreenPosition = CGRectZero
        container.minRectRelativeToScreenPosition = CGRectZero
        container.rowHeight = 0
        
        guard let visibleRange = visibleRangeOfTextView(textView) else {
            assertionFailure("Could not find a visible range in textview \(textView)")
            return container
        }
        let as = textView.attributedText.attributedSubstringFromRange(visibleRange)
        
        
        
    }
    
//    {
//    NSRange visibleRange = [self visibleRangeOfTextView:textView];
//    NSAttributedString *as = [textView.attributedText attributedSubstringFromRange:visibleRange];
//    
//    __block NSInteger minVerse = NSIntegerMax;
//    __block NSInteger maxVerse = 0;
//    
//    __block CGRect minRelativeRect = CGRectZero;
//    __block CGRect maxRelativeRect = CGRectZero;
//    
//    __block BOOL minIsAtStart = NO;
//    __block BOOL maxIsAtEnd = NO;
//    
//    __block CGFloat rowHeight = 0;
//    
//    if (textView == nil) {
//    minVerse = 1;
//    maxVerse = 1;
//    minIsAtStart = YES;
//    rowHeight = 10;
//    }
//    
//    // Go through and find the longest minimum verse and the longest maximum verse
//    [as enumerateAttributesInRange:NSMakeRange(0, as.length) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
//    NSString *verse = attrs[USFM_VERSE_NUMBER];
//    if (verse) {
//    CGRect textFrame = [self frameOfTextRange:range inTextView:textView];
//    rowHeight = fmax(rowHeight, textFrame.size.height);
//    
//    NSInteger number = verse.integerValue;
//    
//    if ( minVerse >= number && textFrame.size.width > 10 && range.length > 5) { // Prevent return characters from causing an issue.
//    CGRect fullRect = [self fullFrameOfVerse:number inTextView:textView];
//    minRelativeRect = fullRect;
//    if ( textView.contentOffset.y < 5.0 ) { // 5 = wiggle room
//    minIsAtStart = YES;
//    }
//    minVerse = number;
//    }
//    if (maxVerse < number || maxVerse == number) {
//    maxVerse = number;
//    maxRelativeRect = [self fullFrameOfVerse:number inTextView:textView];
//    if ( (textView.contentOffset.y + textView.frame.size.height) > (textView.contentSize.height - 10) ) { // 10 = wiggle room
//    maxIsAtEnd = YES;
//    }
//    }
//    }
//    }];
    
//
//    VerseContainer container;
//    
//    container.min = minVerse;
//    container.minIsAtStart = minIsAtStart;
//    container.minRectRelativeToScreenPosition = minRelativeRect;
//    
//    container.max = maxVerse;
//    container.maxIsAtEnd = maxIsAtEnd;
//    container.maxRectRelativeToScreenPosition = maxRelativeRect;
//    
//    container.rowHeight = rowHeight;
//    
//    return container;
//    }
//    
//    - (CGRect)fullFrameOfVerse:(NSInteger)verseNumber inTextView:(UITextView *)textView
//    {
//    __block CGRect frame = CGRectZero;
//    frame.origin.x = CGFLOAT_MAX;
//    frame.origin.y = CGFLOAT_MAX;
//    
//    [textView.attributedText enumerateAttributesInRange:NSMakeRange(0, textView.attributedText.length) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
//    NSString *verse = attrs[USFM_VERSE_NUMBER];
//    if (verse) {
//    NSInteger number = verse.integerValue;
//    if ( verseNumber == number) {
//    CGRect unadjustedFrame = [self unadjustedFrameOfTextRange:range inTextView:textView];
//    unadjustedFrame.origin.y -= textView.contentOffset.y;
//    
//    frame.origin.x = fmin(frame.origin.x, unadjustedFrame.origin.x);
//    frame.origin.y = fmin(frame.origin.y, unadjustedFrame.origin.y);
//    CGFloat currentHeight = (unadjustedFrame.origin.y - frame.origin.y) + unadjustedFrame.size.height;
//    frame.size.height = fmax(frame.size.height, currentHeight);
//    frame.size.width = fmax(frame.size.width, unadjustedFrame.size.width);
//    }
//    }
//    }];
//    return frame;
//    }
//    
//    - (CGRect)frameOfTextRange:(NSRange)range inTextView:(UITextView *)textView {
//    textView.selectedRange = range;
//    UITextRange *textRange = [textView selectedTextRange];
//    CGRect rect = [textView firstRectForRange:textRange];
//    textView.selectedTextRange = nil;
//    return rect;
//    }
//    
//    - (CGRect)unadjustedFrameOfTextRange:(NSRange)range inTextView:(UITextView *)textView {
//    textView.selectedRange = range;
//    UITextRange *textRange = [textView selectedTextRange];
//    
//    CGRect finalRect = CGRectZero;
//    NSArray *selectRects = [textView selectionRectsForRange:textRange];
//    
//    BOOL isSetOnce = NO;
//    for (UITextSelectionRect *textSelRect in selectRects) {
//    CGRect foundRect = textSelRect.rect;
//    if (isSetOnce == NO) {
//    finalRect = foundRect;
//    isSetOnce = YES;
//    }
//    else {
//    finalRect.origin.x = fmin(finalRect.origin.x, foundRect.origin.x);
//    finalRect.origin.y = fmin(finalRect.origin.y, finalRect.origin.y);
//    CGFloat endY = foundRect.size.height + (foundRect.origin.y - finalRect.origin.y);
//    finalRect.size.height = fmax(finalRect.size.height, endY);
//    finalRect.size.width = fmax(finalRect.size.width, foundRect.size.width);
//    }
//    }
//    return finalRect;
//    }
}
