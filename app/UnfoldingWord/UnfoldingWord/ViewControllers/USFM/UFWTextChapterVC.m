//
//  UFWTextChapterVC.m
//  UnfoldingWord
//
//  Created by David Solberg on 5/6/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

#import "UFWTextChapterVC.h"
#import "USFMChapterCell.h"
#import "Constants.h"
#import "UWCoreDataClasses.h"
#import "USFMCoding.h"
#import "EmptyCell.h"
#import "UFWLanguagePickerVC.h"
#import "LanguageInfoController.h"
#import "UFWSelectionTracker.h"
#import "UFWBookPickerUSFMVC.h"
#import "FPPopoverController.h"
#import "UFWStatusInfoViewController.h"
#import "UFWInfoView.h"
#import "ACTLabelButton.h"
#import "UFWNextChapterCell.h"
#import "UIViewController+FileTransfer.h"
#import "UnfoldingWord-Swift.h"

static NSString *kMatchVersion = @"version";
static NSString *kMatchBook = @"book";
static CGFloat kSideMargin = 10.f;

@interface UFWTextChapterVC () <ACTLabelButtonDelegate, UIScrollViewDelegate, UITextViewDelegate>
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSString *cellName;
@property (nonatomic, strong) NSString *cellNameEmpty;
@property (nonatomic, strong) NSString *cellNextChapter;
@property (nonatomic, strong) NSArray *arrayChapters;
@property (nonatomic, assign) NSTextAlignment alignment;
@property (nonatomic, assign) UIInterfaceOrientation lastOrientation;

@property (nonatomic, assign) BOOL didShowPicker;

@property (nonatomic, assign) CGPoint lastCollectionViewScrollOffset;
@property (nonatomic, assign) CGPoint lastTextViewScrollOffset;

@property (nonatomic, strong) FPPopoverController *customPopoverController;
@property (nonatomic, strong) UWTOC* toc;
@property (nonatomic, strong) UWVersion *version;

@end

/*
 TODO:

 Handle cases where there is either either nothing selected or the matching TOC is empty
 
 #warning Need to auto-enter the TOC based on Main or Side TOC
 #warning Need to create a toolbar at the top instead of the navigation bar.
 
 */


@implementation UFWTextChapterVC

- (void)setToc:(UWTOC *)toc
{
    _toc = toc;
    self.version = toc.version;
    self.arrayChapters = [toc.usfmInfo chapters];
    
    [self updateNavTitle];
    [self.collectionView reloadData];
    [self updateContentOffset];
}

-(void)updateNavTitle
{
    ACTLabelButton *labelButton = [[ACTLabelButton alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    labelButton.numberOfLines = 2;
    labelButton.text = [self.toc.title stringByAppendingFormat:@" %ld", (long)[UFWSelectionTracker chapterNumberUSFM]];
    labelButton.font = FONT_MEDIUM;
    labelButton.frame = CGRectMake(0, 0, [labelButton.text widthUsingFont:labelButton.font] + [ACTLabelButton widthForArrow], 38);
    labelButton.delegate = self;
    labelButton.direction = ArrowDirectionDown;
    labelButton.colorNormal = [UIColor whiteColor];
    labelButton.colorHover = [UIColor lightGrayColor];
    labelButton.matchingObject = kMatchBook;
    labelButton.userInteractionEnabled = YES;
    self.navigationItem.titleView = labelButton;
}

- (void)updateContentOffset
{
    NSInteger chapter = [UFWSelectionTracker chapterNumberUSFM];
    // the tens are for margins to match the collectionview which extends 10 points off the left and right side of the frame.
    CGFloat offset = (chapter - 1) * (self.navigationController.view.frame.size.width + kSideMargin + kSideMargin);
    [self.collectionView setContentOffset:CGPointMake(offset, 0) animated:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.collectionView.backgroundColor = BACKGROUND_GRAY;
    
    if (self.isSideTOC) {
        self.toc = [UFWSelectionTracker TOCforUSFMSide];
    }
    else {
        self.toc = [UFWSelectionTracker TOCforUSFM];
    }

    // Register cells
    self.cellName = NSStringFromClass([USFMChapterCell class]);
    UINib *nib = [UINib nibWithNibName:self.cellName bundle:nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:self.cellName];
    
    self.cellNameEmpty = NSStringFromClass([EmptyCell class]);
    UINib *emptyNib = [UINib nibWithNibName:self.cellNameEmpty bundle:nil];
    [self.collectionView registerNib:emptyNib forCellWithReuseIdentifier:self.cellNameEmpty];
    
    self.cellNextChapter = NSStringFromClass([UFWNextChapterCell class]);
    UINib *nextNib = [UINib nibWithNibName:self.cellNextChapter bundle:nil];
    [self.collectionView registerNib:nextNib forCellWithReuseIdentifier:self.cellNextChapter];
    
    [self addBarButtonItems];
}

- (void)addBarButtonItems
{
    ACTLabelButton *labelButton = [[ACTLabelButton alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
    labelButton.text = NSLocalizedString(@"Version", nil);
    labelButton.delegate = self;
    labelButton.direction = ArrowDirectionDown;
    labelButton.colorNormal = [UIColor whiteColor];
    labelButton.colorHover = [UIColor lightGrayColor];
    labelButton.matchingObject = kMatchVersion;
    labelButton.userInteractionEnabled = YES;
    UIBarButtonItem *bbiVersion = [[UIBarButtonItem alloc] initWithCustomView:labelButton];
    
    UIButton *buttonStatus = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 26, 26)];
    [buttonStatus setImage:[UFWInfoView imageReverseForStatus:self.toc.version.status] forState:UIControlStateNormal];
    [buttonStatus addTarget:self action:@selector(showPopOverStatusInfo:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *bbiStatus = [[UIBarButtonItem alloc] initWithCustomView:buttonStatus];
    
    UIBarButtonItem *bbiShare = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(userRequestedSharing:)];
    
    self.navigationItem.rightBarButtonItems = @[bbiShare, bbiVersion, bbiStatus];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view layoutIfNeeded];
    if ([self checkForRotationChange] == YES) {
        [self.collectionView reloadData];
    }
    [self updateContentOffset];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.toc == nil && self.didShowPicker == NO) {
        [self userRequestedLanguageSelector:nil];
        self.didShowPicker = YES;
    }
}

- (void)labelButtonPressed:(ACTLabelButton *)labelButton;
{
    NSString *matchingObject = labelButton.matchingObject;
    if ([matchingObject isKindOfClass:[NSString class]]) {
        if ([matchingObject isEqualToString:kMatchVersion]) {
            [self userRequestedLanguageSelector:labelButton];
        }
        else if ([matchingObject isEqualToString:kMatchBook]) {
            [self userRequestedBookPicker:labelButton];
        }
    }
    else {
        NSAssert2(NO, @"%s: matching object %@ not recognized!", __PRETTY_FUNCTION__, matchingObject);
    }
}


#pragma mark - Sharing

- (void)userRequestedSharing:(UIBarButtonItem *)activityBarButtonItem
{
    if (self.toc.version == nil) {
        return;
    }
    [self sendFileForVersion:self.toc.version];
}


#pragma mark - Language Picker

- (void)userRequestedLanguageSelector:(id)sender
{
    __weak typeof(self) weakself = self;
    UIViewController *navVC = [UFWLanguagePickerVC navigationLanguagePickerWithTopContainer:self.toc.version.language.topContainer completion:^(BOOL isCanceled, UWVersion *versionPicked) {
        [weakself dismissViewControllerAnimated:YES completion:^{}];
        
        if (isCanceled) {
            return;
        }
        
        NSArray *arrayTOCs = versionPicked.sortedTOCs;
        if (arrayTOCs.count == 0) {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"There is no content for the selected version.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss", nil) otherButtonTitles: nil] show];
            return;
        }
        
        if (weakself.toc == nil) {
            weakself.toc = arrayTOCs[0];
        }
        else {
            BOOL success = NO;
            for (UWTOC *toc in versionPicked.toc) {
                if ([toc.slug isKindOfClass:[NSString class]] == NO) {
                    NSAssert2(NO, @"%s: The toc did not have a slug. No way to track it: %@", __PRETTY_FUNCTION__, toc);
                    continue;
                }
                if ([weakself.toc.slug isEqualToString:toc.slug]) {
                    weakself.toc = toc;
                    success = YES;
                    break;
                }
            }
            if (success == NO) { // No slug matches
                weakself.toc = arrayTOCs[0];
            }
        }
        [UFWSelectionTracker setUSFMTOC:self.toc];
        [weakself addBarButtonItems];
    }];
    
    [self presentViewController:navVC animated:YES completion:^{}];
}

#pragma mark - Book Chapter PIcker
- (void)userRequestedBookPicker:(id)sender
{
    UIViewController *navVC = [UFWBookPickerUSFMVC navigationBookPickerWithVersion:self.toc.version completion:^(BOOL isCanceled, UWTOC *tocPicked, NSInteger chapterPicked) {
        [self dismissViewControllerAnimated:YES completion:^{}];
        
        if (isCanceled || tocPicked == nil || chapterPicked <= 0) {
            return;
        }
        
        [UFWSelectionTracker setChapterUSFM:chapterPicked];
        [UFWSelectionTracker setUSFMTOC:tocPicked];
        self.toc = tocPicked;
        
    }];
    
    [self presentViewController:navVC animated:YES completion:^{
        
    }];
}

#pragma mark - Version Info Popover

- (void)showPopOverStatusInfo:(id)sender
{
    UFWStatusInfoViewController *statusVC = [[UFWStatusInfoViewController alloc] init];
    statusVC.status = self.toc.version.status;
    CGFloat width = fmin((self.view.frame.size.width - 40), 540);
    CGSize size = [UFWInfoView sizeForStatus:self.toc.version.status forWidth:width withDeleteButton:NO];
    self.customPopoverController = [[FPPopoverController alloc] initWithViewController:statusVC delegate:nil maxSize:size];
    self.customPopoverController.border = NO;
    [self.customPopoverController setShadowsHidden:YES];
    
    if ([sender isKindOfClass:[UIView class]]) {
        self.customPopoverController.arrowDirection = FPPopoverArrowDirectionAny;
        [self.customPopoverController presentPopoverFromView:(UIView *)sender];
    }
    else {
        self.customPopoverController.arrowDirection = FPPopoverNoArrow;
        [self.customPopoverController presentPopoverFromView:self.view];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.arrayChapters.count == 0) {
        return 1;
    }
    else {
        return ([self nextTOC] == nil) ? self.arrayChapters.count : self.arrayChapters.count + 1;
    }
}

// Note the collection view is actually 10 points larger on left and right, and the corresponding cell is also larger. This allows the illusion of space between the cells.
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.arrayChapters.count == 0) {
        EmptyCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.cellNameEmpty forIndexPath:indexPath];
        return cell;
    }
    else if (indexPath.row < self.arrayChapters.count) {
        USFMChapterCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.cellName forIndexPath:indexPath];
        USFMChapter *chapter = self.arrayChapters[indexPath.row];
        cell.textView.attributedText = chapter.attributedString;
        cell.textView.textAlignment = [LanguageInfoController textAlignmentForLanguageCode:self.toc.version.language.lc];
        cell.textView.contentOffset = CGPointMake(0, 0);
        return cell;
    }
    else {
        UFWNextChapterCell *nextChapterCell = [collectionView dequeueReusableCellWithReuseIdentifier:self.cellNextChapter forIndexPath:indexPath];
        UWTOC *nextToc = [self nextTOC];
        NSString *goToString = NSLocalizedString(@"Go to", @"The name of the bible chapter or book is put after the go to text.");
        [nextChapterCell.buttonNextChapter setTitle:[NSString stringWithFormat:@"%@ %@", goToString, nextToc.title] forState:UIControlStateNormal];
        if (nextChapterCell.buttonNextChapter.allTargets.count == 0) {
            [nextChapterCell.buttonNextChapter addTarget:self action:@selector(onNextBookTouched:) forControlEvents:UIControlEventTouchUpInside];
        }
        return nextChapterCell;
    }
}

- (void)onNextBookTouched:(id)sender
{
    [self animateToNextTOC];
}

- (void)animateToNextTOC
{
    UWTOC *nextTOC = [self nextTOC];
    if (nextTOC == nil) {
        NSAssert2(NO, @"%s: Could not find next toc in array %@", __PRETTY_FUNCTION__, self.arrayChapters);
        return;
    }
    
    _toc = nextTOC;
    self.arrayChapters = [self.toc.usfmInfo chapters];
    
    [UFWSelectionTracker setChapterUSFM:1];
    [UFWSelectionTracker setUSFMTOC:nextTOC];
    
    
    NSIndexPath *nextIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    
    [self.collectionView scrollToItemAtIndexPath:nextIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    
    CGRect cFrame = self.collectionView.frame;
    [self.collectionView setFrame:CGRectMake(cFrame.size.width,cFrame.origin.y,cFrame.size.width, cFrame.size.height)];
    
    [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction animations:^{
        [self.collectionView setFrame:cFrame];
    } completion:^(BOOL finished){
        [self.collectionView reloadData];
        [self updateNavTitle];
        // do whatever post processing you want (such as resetting what is "current" and what is "next")
    }];
}

- (UWTOC *)nextTOC
{
    if (self.toc == nil) {
        return nil;
    }
    
    NSArray *sortedTOCs = [self.toc.version sortedTOCs];
    NSInteger currentIndex = -1;
    for (int i = 0; i < sortedTOCs.count ; i++) {
        UWTOC *toc = sortedTOCs[i];
        if ([toc isEqual:self.toc]) {
            currentIndex = i;
        }
    }
    NSInteger nextIndex = currentIndex + 1;
    if ( nextIndex < sortedTOCs.count ) {
        return sortedTOCs[nextIndex];
    }
    else {
        return nil;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = self.collectionView.frame.size;
    return size;
}

#pragma mark - Rotation

- (BOOL)checkForRotationChange
{
    UIInterfaceOrientation currentOrient = [[UIApplication sharedApplication] statusBarOrientation];
    if (self.lastOrientation == 0) {
        self.lastOrientation = currentOrient;
        return NO;
    }
    else if ( UIInterfaceOrientationIsLandscape(self.lastOrientation) && UIInterfaceOrientationIsLandscape(currentOrient)) {
        return NO;
    }
    else if ( UIInterfaceOrientationIsPortrait(self.lastOrientation) && UIInterfaceOrientationIsPortrait(currentOrient)) {
        return NO;
    }
    else {
        self.lastOrientation = currentOrient;
        return YES;
    }
}

-(void) willRotateToInterfaceOrientation: (UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.customPopoverController dismissPopoverAnimated:YES];
    
    if (self.lastOrientation != 0) {
        if ( UIInterfaceOrientationIsLandscape(self.lastOrientation) && UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
            return;
        }
        if ( UIInterfaceOrientationIsPortrait(self.lastOrientation) && UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
            return;
        }
    }
    
    CGRect windowFrame = [[UIScreen mainScreen] bounds];
    CGFloat height = 0;
    if (self.view.bounds.size.width > self.view.bounds.size.height) {
        height = fmin(windowFrame.size.height, windowFrame.size.width);
    }
    else {
        height = fmax(windowFrame.size.height, windowFrame.size.width);
    }
    
    CGPoint currentOffset = self.collectionView.contentOffset;
    CGFloat offsetIndex = (int)currentOffset.x / (self.collectionView.bounds.size.width);
    CGFloat newOffsetX = offsetIndex * (height + kSideMargin + kSideMargin);
    CGPoint newOffset = CGPointMake(newOffsetX, 0);
    
    self.collectionView.layer.opacity = 0.0;
    
    [UIView animateWithDuration:duration delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        
    } completion:^(BOOL finished) {
        [self.collectionView setContentOffset:newOffset];
        [UIView animateWithDuration:.35 delay:.15 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.collectionView.layer.opacity = 1.0;
        } completion:^(BOOL finished) {}];
    }];
    [self.collectionView reloadData];
    
    self.lastOrientation = toInterfaceOrientation;
}

#pragma mark - Syncing Methods with Matching View Controller

- (void)scrollCollectionView:(CGFloat)offset;
{
    CGPoint point = self.collectionView.contentOffset;
    point.x += offset;
    [self.collectionView setContentOffset:point];
}

- (void)scrollTextView:(CGFloat)offset;
{
    USFMChapterCell *cell = [self visibleChapterCell];
    CGPoint adjustedPoint = cell.textView.contentOffset;
    adjustedPoint.y += offset;
    cell.textView.contentOffset = adjustedPoint;
}

- (void)adjustTextViewWithVerses:(VerseContainer)verses;
{
    USFMChapterCell *cell = [self visibleChapterCell];
    if (cell == nil) {
        return;
    }
    
    UITextView *textView = cell.textView;
    
    NSAttributedString *as = textView.attributedText;
    __block NSRange startVerseRange = NSMakeRange(NSNotFound, 0);
    __block NSRange endVerseRange = NSMakeRange(NSNotFound, 0);
    
    [as enumerateAttributesInRange:NSMakeRange(0, as.length) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        NSString *verse = attrs[USFM_VERSE_NUMBER];
        if (verse) {
            NSInteger number = verse.integerValue;
            if (number == verses.min) {
                startVerseRange = range;
            }
            else if (number == verses.max) {
                endVerseRange = range;
            }
        }
    }];
    
    NSAssert3(startVerseRange.location != NSNotFound && endVerseRange.location != NSNotFound, @"%s: We didn't even find the range of text for startRange %@ and endRange %@", __PRETTY_FUNCTION__, NSStringFromRange(startVerseRange), NSStringFromRange(endVerseRange));
    
    NSRange visibleRange = [self visibleRangeOfTextView:textView];
    
    if (visibleRange.location > startVerseRange.location) {
        [textView scrollRangeToVisible:startVerseRange];
    }
}

- (void)changeToMatchingTOC:(UWTOC* __nullable)toc;
{
    if (toc == nil) {
        self.toc = nil;
    }
    else {
        BOOL success = NO;
        for (UWTOC *toc in self.version.toc) {
            if ([toc.slug isKindOfClass:[NSString class]] == NO) {
                NSAssert2(NO, @"%s: The toc did not have a slug. No way to track it: %@", __PRETTY_FUNCTION__, toc);
                continue;
            }
            if ([self.toc.slug isEqualToString:toc.slug]) {
                self.toc = toc;
                success = YES;
                break;
            }
        }
        if (success == NO) { // No slug matches
            self.toc = nil;
        }
    }
}

-(NSRange)visibleRangeOfTextView:(UITextView *)textView
{
    CGRect bounds = textView.frame;
    bounds.origin = textView.contentOffset; // Scrolling changes the bounds of the view, but the size will be the same.
    bounds.size.height -= 30.0f; // Not interested in anything near the bottom edge.
    
    UITextPosition *start = [textView characterRangeAtPoint:bounds.origin].start;
    UITextPosition *end = [textView characterRangeAtPoint:CGPointMake(CGRectGetMaxX(bounds), CGRectGetMaxY(bounds))].end;
    
    float location = [textView offsetFromPosition:textView.beginningOfDocument toPosition:start];
    float length = [textView offsetFromPosition:textView.beginningOfDocument toPosition:end] - location;
    
    return NSMakeRange(location, length);
}


#pragma mark - Scroll View Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint offsetCurrent = scrollView.contentOffset;
    if ([scrollView isEqual:self.collectionView]) {
        CGFloat difference = offsetCurrent.x - self.lastCollectionViewScrollOffset.x;
        [self.delegate userDidScrollWithVc:self horizontalOffset:difference];
        self.lastCollectionViewScrollOffset = offsetCurrent;
    }
    else {
        USFMChapterCell *cell = [self visibleChapterCell];
        
        if ([cell.textView isEqual:scrollView]) {
            CGFloat difference = offsetCurrent.y -self.lastTextViewScrollOffset.y;
            [self.delegate userDidScrollWithVc:self verticalOffset:difference];
            self.lastTextViewScrollOffset = offsetCurrent;
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self handleScrollViewDoneDragging:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ( ! decelerate) {
        [self handleScrollViewDoneDragging:scrollView];
    }
}

- (void)handleScrollViewDoneDragging:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:self.collectionView]) {
        [self updateCurrentChapter];
    }
    else {
        USFMChapterCell *cell = [self visibleChapterCell];
        if ([cell.textView isEqual:scrollView]) {
            VerseContainer verses = [self versesInTextView:cell.textView];
            [self.delegate userFinishedScrollingWithVc:self verses:verses];
        }
    }
}

- (VerseContainer)versesInTextView:(UITextView *)textView
{
    NSAttributedString *as = textView.attributedText;
    __block NSInteger lowestVerse = NSIntegerMax;
    __block NSInteger highestVerse = 0;
    
    [as enumerateAttributesInRange:NSMakeRange(0, as.length) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        NSString *verse = attrs[USFM_VERSE_NUMBER];
        if (verse) {
            NSInteger number = verse.integerValue;
            lowestVerse = MIN(lowestVerse, number);
            highestVerse = MAX(highestVerse, number);
        }
    }];
    
    VerseContainer container;
    container.min = lowestVerse;
    container.max = highestVerse;
    return container;
}

- (void)updateCurrentChapter
{
    CGFloat offset = self.collectionView.contentOffset.x;
    NSInteger index = round(offset/self.collectionView.frame.size.width);
    NSInteger chapter = index + 1;
    if (chapter <= self.arrayChapters.count) {
        [UFWSelectionTracker setChapterUSFM:chapter];
        [self updateNavTitle];
    }
}

#pragma mark - Helpers

/// Returns the current chapter cell if available. Will be nil if no cells or if the current cell is of the wrong type.
- (USFMChapterCell *)visibleChapterCell
{
    CGPoint offset = self.collectionView.contentOffset;
    for (USFMChapterCell *chapterCell in self.collectionView.visibleCells) {
        if ([chapterCell isKindOfClass:[USFMChapterCell class]]) {
            if (chapterCell.frame.origin.x == offset.x) {
                return chapterCell;
            }
        }
    }
    return nil;
}

@end
