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
#import "UFWVersionPickerVC.h"
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

@interface UFWTextChapterVC () <ACTLabelButtonDelegate, UIScrollViewDelegate, UITextViewDelegate, UICollectionViewDelegate>
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSString *cellName;
@property (nonatomic, strong) NSString *cellNameEmpty;
@property (nonatomic, strong) NSString *cellNextChapter;
@property (nonatomic, strong) NSArray *arrayChapters;
@property (nonatomic, assign) NSTextAlignment alignment;
@property (nonatomic, assign) UIInterfaceOrientation lastOrientation;
@property (nonatomic, weak) IBOutlet UIToolbar *toolBar;

@property (nonatomic, assign) BOOL didShowPicker;

@property (nonatomic, assign) CGPoint lastCollectionViewScrollOffset;
@property (nonatomic, assign) CGPoint lastTextViewScrollOffset;
@property (nonatomic, assign) CGFloat matchingCollectionViewXOffset;

@property (nonatomic, strong) FPPopoverController *customPopoverController;
@property (nonatomic, strong) UWTOC* toc;
@property (nonatomic, strong) UWVersion *version;

@property (nonatomic, assign) NSInteger countSetup;

@end


@implementation UFWTextChapterVC

- (void)setToc:(UWTOC *)toc
{
    _toc = toc;
    if (toc != nil) {
        self.version = toc.version;
        self.topContainer = toc.version.language.topContainer;
        [self updateSelectionTOC:toc];
    }

    self.arrayChapters = [toc.usfmInfo chapters];
    
    [self.collectionView reloadData];
    [self updateContentOffset];
}

- (void)updateSelectionTOC:(UWTOC *)toc
{
    if (self.isSideTOC) {
        [UFWSelectionTracker setUSFMTOCSide:toc];
    }
    else {
        [UFWSelectionTracker setUSFMTOC:toc];
    }
}

- (void)updateContentOffset
{
    [self willSetup];
    NSInteger chapter = [UFWSelectionTracker chapterNumberUSFM];
    // the tens are for margins to match the collectionview which extends 10 points off the left and right side of the frame.
    CGFloat offset = (chapter - 1) * (self.view.frame.size.width + kSideMargin + kSideMargin);
    [self.collectionView setContentOffset:CGPointMake(offset, 0) animated:NO];
    self.lastCollectionViewScrollOffset = self.collectionView.contentOffset;
    [self didSetup];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.countSetup = 0;
    
    self.toolBar.tintColor = [UIColor whiteColor];
    self.toolBar.barTintColor = BACKGROUND_GRAY;
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

// For some reason, Apple seems to have non-zeroing references to some delegates, so we have to zero them out so that messages don't get sent to this object after it's dealloc'd
- (void)dealloc
{
    USFMChapterCell *visibleChapterCell = [self visibleChapterCell];
    visibleChapterCell.textView.delegate = nil;
    self.collectionView.delegate = nil;
    self.collectionView.dataSource = nil;
    
}

- (void)updateVersionTitle
{
    if (self.toolBar.items.count == 0) {
        return;
    }
    NSMutableArray *items = self.toolBar.items.mutableCopy;
    NSInteger foundIndex = -1;
    NSInteger index = 0;
    for (UIBarButtonItem *bbi in items) {
        if ([bbi.customView isKindOfClass:[ACTLabelButton class]]) {
            ACTLabelButton *button = (ACTLabelButton *)bbi.customView;
            if (button.matchingObject == kMatchVersion) {
                foundIndex = index;
                break;
            }
        }
    }
    NSAssert2(foundIndex != -1, @"%s: Could  not find the chapter in %@", __PRETTY_FUNCTION__, items);
    
    if (foundIndex >= 0) {
        UIBarButtonItem *bbiChapter = [[UIBarButtonItem alloc] initWithCustomView:[self navVersionButton]];
        [items replaceObjectAtIndex:foundIndex withObject:bbiChapter];
        self.toolBar.items = items;
    }
}

- (void)addBarButtonItems
{
    UIBarButtonItem *bbiVersion = [[UIBarButtonItem alloc] initWithCustomView:[self navVersionButton]];

    UIBarButtonItem *bbiSpacer =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIButton *buttonStatus = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 26, 26)];
    [buttonStatus setImage:[UFWInfoView imageReverseForStatus:self.toc.version.status] forState:UIControlStateNormal];
    [buttonStatus addTarget:self action:@selector(showPopOverStatusInfo:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *bbiStatus = [[UIBarButtonItem alloc] initWithCustomView:buttonStatus];
    
    UIBarButtonItem *bbiShare = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(userRequestedSharing:)];
    self.toolBar.items = @[ bbiVersion, bbiSpacer, bbiStatus, bbiShare];
}

-(ACTLabelButton *)navVersionButton
{
    ACTLabelButton *labelButton = [[ACTLabelButton alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    labelButton.text = (self.version.name != nil) ? self.version.name : NSLocalizedString(@"Version", nil);
    CGFloat availableWidth = self.toolBar.frame.size.width - 100.0f; // need 100 for other elements on the bar.
    CGFloat specifiedWidth = fminf([labelButton.text widthUsingFont:labelButton.font] + [ACTLabelButton widthForArrow], availableWidth);
    labelButton.frame = CGRectMake(0, 0,specifiedWidth, 30);
    
    labelButton.adjustsFontSizeToFitWidth = YES;
    labelButton.minimumScaleFactor = 0.8;
    labelButton.delegate = self;
    labelButton.direction = ArrowDirectionDown;
    labelButton.colorNormal = [UIColor whiteColor];
    labelButton.colorHover = [UIColor lightGrayColor];
    labelButton.matchingObject = kMatchVersion;
    labelButton.userInteractionEnabled = YES;
    return labelButton;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view layoutIfNeeded];
    if ([self checkForRotationChange] == YES) {
        [self willSetup];
        [self.collectionView reloadData];
        [self didSetup];
    }
    [self updateContentOffset];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.toc == nil && self.didShowPicker == NO && [self isSideTOC] ==  NO) {
        [self userRequestedVersionPicker:nil];
        self.didShowPicker = YES;
    }
}

- (void)labelButtonPressed:(ACTLabelButton *)labelButton;
{
    NSString *matchingObject = labelButton.matchingObject;
    if ([matchingObject isKindOfClass:[NSString class]]) {
        if ([matchingObject isEqualToString:kMatchVersion]) {
            [self userRequestedVersionPicker:labelButton];
        }
        else if ([matchingObject isEqualToString:kMatchBook]) {
            [self userRequestedBookPicker:labelButton];
        }
    }
    else {
        NSAssert2(NO, @"%s: matching object %@ not recognized!", __PRETTY_FUNCTION__, matchingObject);
    }
}

- (void)bookButtonPressed
{
    [self userRequestedBookPicker:self];
}


#pragma mark - Sharing

- (void)userRequestedSharing:(UIBarButtonItem *)activityBarButtonItem
{
    if (self.toc.version == nil) {
        return;
    }
    [self sendFileForVersion:self.toc.version fromBarButtonOrView:activityBarButtonItem];
}


#pragma mark - Language Picker

- (void)userRequestedVersionPicker:(id)sender
{
    __weak typeof(self) weakself = self;

    UIViewController *navVC = [UFWVersionPickerVC navigationLanguagePickerWithTopContainer:self.topContainer isSide:NO completion:^(BOOL isCanceled, UWVersion *versionPicked) {
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
        [weakself updateSelectionTOC:weakself.toc];
        [weakself.delegate userChangedTOCWithVc:self pickedTOC:weakself.toc];
        [weakself addBarButtonItems];
    }];
    
    [self presentViewController:navVC animated:YES completion:^{}];
}


#pragma mark - Book Chapter PIcker
- (void)userRequestedBookPicker:(id)sender
{
    __weak typeof(self) weakself = self;
    UIViewController *navVC = [UFWBookPickerUSFMVC navigationBookPickerWithVersion:self.toc.version completion:^(BOOL isCanceled, UWTOC *tocPicked, NSInteger chapterPicked) {
        [weakself dismissViewControllerAnimated:YES completion:^{}];
        
        if (isCanceled || tocPicked == nil || chapterPicked <= 0) {
            return;
        }
        
        [UFWSelectionTracker setChapterUSFM:chapterPicked];
        [weakself updateSelectionTOC:tocPicked];
        [weakself.delegate userChangedTOCWithVc:self pickedTOC:tocPicked];
        weakself.toc = tocPicked;
    }];
    
    [self presentViewController:navVC animated:YES completion:^{}];
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
        cell.textView.delegate = self;
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
    [self willSetup];
    UWTOC *nextTOC = [self nextTOC];

    if (nextTOC == nil) {
        NSAssert2(NO, @"%s: Could not find next toc in array %@", __PRETTY_FUNCTION__, self.arrayChapters);
        return;
    }
    
    _toc = nextTOC;
    self.arrayChapters = [self.toc.usfmInfo chapters];
    
    [UFWSelectionTracker setChapterUSFM:1];
    [self updateSelectionTOC:nextTOC];
    
    NSIndexPath *nextIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    
    [self.collectionView scrollToItemAtIndexPath:nextIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    
    CGRect cFrame = self.collectionView.frame;
    [self.collectionView setFrame:CGRectMake(cFrame.size.width,cFrame.origin.y,cFrame.size.width, cFrame.size.height)];
    
    [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction animations:^{
        [self.collectionView setFrame:cFrame];
    } completion:^(BOOL finished){
        [self.collectionView reloadData];
        self.lastCollectionViewScrollOffset = self.collectionView.contentOffset;
        [self didSetup];
        [self.delegate userChangedTOCWithVc:self pickedTOC:nextTOC];
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

// If this vc's view is hidden (for example, it is presenting another view controller), then it never gets notified of any user rotation events. This method remembers the last orientation and checks.
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
    
    USFMTextLocationInfo *currentTextLocation = [self currentTextLocation];

    CGFloat expectedWidth = [self.delegate expectedContainerWidthAfterRotation];
    
    CGFloat offsetIndex = [self currentIndex];
    CGFloat newOffsetX = offsetIndex * (expectedWidth + kSideMargin + kSideMargin);
    CGPoint newOffset = CGPointMake(newOffsetX, 0);
    
    self.collectionView.layer.opacity = 0.0;
    
    [self willSetup];
    [UIView animateWithDuration:duration delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        
    } completion:^(BOOL finished) {
        [self.collectionView setContentOffset:newOffset];
        self.lastCollectionViewScrollOffset = self.collectionView.contentOffset;
        [self scrollToLocation:currentTextLocation animated:NO];
        [self updateVersionTitle];
        [UIView animateWithDuration:.35 delay:.15 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.collectionView.layer.opacity = 1.0;
        } completion:^(BOOL finished) {
            [self didSetup];
        }];
    }];
    [self.collectionView reloadData];
    
    self.lastOrientation = toInterfaceOrientation;
}

- (void) changeToSize:(CGSize)size
{
    [self willSetup];
    [self.collectionView setNeedsUpdateConstraints];
    [self.collectionView performBatchUpdates:^{
        [self.collectionView layoutIfNeeded];
        [self.collectionView.collectionViewLayout invalidateLayout];
    } completion:^(BOOL finished) {
        self.matchingCollectionViewXOffset = 0.0f;
        [self didSetup];
    }];
}

#pragma mark - Syncing Methods with Matching View Controller

- (void)scrollCollectionView:(CGFloat)offset;
{
    [self willSetup];
    self.matchingCollectionViewXOffset += offset;
    [self setFadeWithPoints:self.matchingCollectionViewXOffset];
    
    CGPoint point = self.collectionView.contentOffset;
    point.x += offset;
    [self.collectionView setContentOffset:point];
    self.lastCollectionViewScrollOffset = self.collectionView.contentOffset;
    [self didSetup];
}

- (void)setFadeWithPoints:(CGFloat)points
{
    points = fabs(points);
    CGFloat amountToFullFade = 30.0f;
    CGFloat fullFade = 0.0f;
    CGFloat percent = (points > amountToFullFade) ? 0.0f : (amountToFullFade-points) / amountToFullFade;
    CGFloat opacity = fullFade + ( (1-fullFade) * percent);
    self.collectionView.layer.opacity = opacity;
}

- (void)scrollTextView:(CGFloat)offset;
{
    [self willSetup];
    USFMChapterCell *cell = [self visibleChapterCell];
    CGPoint adjustedPoint = cell.textView.contentOffset;
    adjustedPoint.y += offset;
    adjustedPoint.y = fmaxf(adjustedPoint.y, 0);
    adjustedPoint.y = fminf(adjustedPoint.y, cell.textView.contentSize.height - cell.textView.frame.size.height);
    cell.textView.contentOffset = adjustedPoint;
    
    [self didSetup];
}

- (void)adjustTextViewWithVerses:(VerseContainer)remoteVerses animationDuration:(CGFloat)duration
{
    USFMChapterCell *cell = [self visibleChapterCell];
    if (cell == nil) {
        return;
    }
    
    [self willSetup];
    
    UITextView *textView = cell.textView;
    NSAttributedString *as = textView.attributedText;
    NSInteger verseToFind = (remoteVerses.maxIsAtEnd) ? remoteVerses.max : remoteVerses.min;
    
    CGFloat minY = [self minYForVerse:verseToFind inAttributedString:as inTextView:textView];
    
    CGFloat relativeOffset = 0;
    
    CGFloat yOriginOffset = remoteVerses.minRectRelativeToScreenPosition.origin.y;
    CGFloat verseHeight = remoteVerses.minRectRelativeToScreenPosition.size.height;
    
    CGFloat remoteVisiblePoints = verseHeight + yOriginOffset;
    
    CGFloat remotePercentAboveOrigin = remoteVisiblePoints / verseHeight;
    CGFloat percentBelowOrigin = 1 - remotePercentAboveOrigin;
    
    CGFloat nextY = [self minYForVerse:verseToFind+1 inAttributedString:as inTextView:textView];
    CGFloat distanceBetweenVerses = nextY - minY;
    
    if (remoteVisiblePoints < 90 && verseHeight > 90) {
        // 90 points is approximately a line or two. If we only have a couple of lines, then just match with the next verse, balanced by the percent showing across verses
        minY = nextY;
        relativeOffset = remoteVisiblePoints * remotePercentAboveOrigin;
    }
    else {
        // Trying to show relatively the same amount of verse for both sides. This is important because some verses are more than twice as long as their matching verses in another language or bible version.
        relativeOffset = -distanceBetweenVerses * percentBelowOrigin;
    }
    
    // Adjust so the first visible verse starts in the same place on both screens.
    minY -= relativeOffset;

    // Prevent the screen from scrolling past the end
    minY = fmin(minY, textView.contentSize.height - textView.frame.size.height);

    CGFloat offset = fabs( textView.contentOffset.y - minY);
    if (offset > textView.frame.size.height) {
        // Scrollview jumps around by some other method. Still trying to track down why this happens.
        NSLog(@"Offset larger than expected.");
    }
    
    if (duration > 0.001) {
        textView.userInteractionEnabled = NO;
        [textView setContentOffset:CGPointMake(0, minY) animated:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            textView.userInteractionEnabled = YES;
            [self didSetup];
        });
    }
    else {
        textView.contentOffset = CGPointMake(0, minY);
        [self didSetup];
    }
}

- (CGFloat)minYForVerse:(NSInteger)verseToFind inAttributedString:(NSAttributedString *)as inTextView:(UITextView *)textView
{
    __block CGFloat minY = CGFLOAT_MAX;
    [as enumerateAttributesInRange:NSMakeRange(0, as.length) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        NSString *verse = attrs[USFM_VERSE_NUMBER];
        if (verse) {
            NSInteger number = verse.integerValue;
            if (number == verseToFind) {
                CGRect locationRect = [self frameOfTextRange:range inTextView:textView];
                minY = fmin(minY, locationRect.origin.y);
            }
        }
    }];
    return minY;
}

- (void)changeToMatchingTOC:(UWTOC* __nullable)matchingTOC;
{
    if (matchingTOC == nil) {
        self.toc = nil;
        return;
    }
    else {
        BOOL success = NO;
        for (UWTOC *tocCandidate in self.version.toc) {
            if ([tocCandidate.slug isKindOfClass:[NSString class]] == NO) {
                NSAssert2(NO, @"%s: The toc did not have a slug. No way to track it: %@", __PRETTY_FUNCTION__, tocCandidate);
                continue;
            }
            if ([matchingTOC.slug isEqualToString:tocCandidate.slug]) {
                self.toc = tocCandidate;
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

- (void)matchingCollectionViewDidFinishScrolling
{
    // Fade back in.
    self.matchingCollectionViewXOffset = 0.0f;
    [UIView animateWithDuration:0.5 animations:^{
        self.collectionView.layer.opacity = 1.0;
    } completion:^(BOOL finished) {
        
    }];
}

- (USFMTextLocationInfo *)currentTextLocation;
{
    USFMChapterCell *visibleCell = [self visibleChapterCell];
    NSRange range = [self visibleRangeOfTextView:visibleCell.textView];
    return [[USFMTextLocationInfo alloc] initWithRange:range index:[UFWSelectionTracker chapterNumberUSFM]-1];
}

- (void)scrollToLocation:(USFMTextLocationInfo *)location animated:(BOOL)animated
{
    CGFloat duration = (animated == YES) ? 0.25 : 0.0;
    [self willSetup];
    CGFloat offset = location.indexChapter * (self.view.frame.size.width + kSideMargin + kSideMargin);
    
    [UIView animateWithDuration:duration animations:^{
        [self.collectionView setContentOffset:CGPointMake(offset, 0)];
        self.lastCollectionViewScrollOffset = self.collectionView.contentOffset;
    } completion:^(BOOL finished) {
        USFMChapterCell *visibleCell = [self visibleChapterCell];
        UITextView *textView = visibleCell.textView;
        CGRect firstRect = [self frameOfTextRange:location.textRange inTextView:textView];
        [UIView animateWithDuration:duration animations:^{
            CGPoint offset = CGPointMake(0, firstRect.origin.y);
            [textView setContentOffset:offset];
        } completion:^(BOOL finished) {
            [self didSetup];
        }];
    }];
}

#pragma mark - Prevent Double Scrolling

- (void)willSetup
{
    self.countSetup++;
}

- (void)didSetup
{
    self.countSetup--;
}

- (BOOL)isSettingUp
{
    return (self.countSetup > 0) ? YES : NO;
}

#pragma mark - Scroll View Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.isSettingUp) {
        return;
    }
    
    CGPoint offsetCurrent = scrollView.contentOffset;
    if ([scrollView isEqual:self.collectionView]) {
        CGFloat difference = offsetCurrent.x - self.lastCollectionViewScrollOffset.x;
        [self.delegate userDidScrollWithVc:self horizontalOffset:difference];
        self.lastCollectionViewScrollOffset = offsetCurrent;
    }
    else {
        USFMChapterCell *cell = [self visibleChapterCell];
        
        if ([cell.textView isEqual:scrollView]) {
            CGFloat difference = offsetCurrent.y - self.lastTextViewScrollOffset.y;
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
    if (self.isSettingUp) {
        return;
    }
    
    if ([scrollView isEqual:self.collectionView]) {
        [self updateCurrentChapter];
        [self.delegate userFinishedScrollingCollectionViewWithVc:self];
    }
    else {
        USFMChapterCell *cell = [self visibleChapterCell];
        if ([cell.textView isEqual:scrollView]) {
            VerseContainer verses = [self versesInTextView:cell.textView];
            [self.delegate userFinishedScrollingWithVc:self verses:verses];
        }
    }
}

- (void)updateCurrentChapter
{
    CGFloat offset = self.collectionView.contentOffset.x;
    NSInteger index = round(offset/self.collectionView.frame.size.width);
    NSInteger chapter = index + 1;
    if (chapter <= self.arrayChapters.count) {
        [UFWSelectionTracker setChapterUSFM:chapter];
    }
}

#pragma mark - Helpers

- (VerseContainer)versesVisible
{
    USFMChapterCell *cell = [self visibleChapterCell];
    return  [self versesInTextView:cell.textView];
}

- (VerseContainer)versesInTextView:(UITextView *)textView
{
    NSRange visibleRange = [self visibleRangeOfTextView:textView];
    NSAttributedString *as = [textView.attributedText attributedSubstringFromRange:visibleRange];
    
    __block NSInteger minVerse = NSIntegerMax;
    __block NSInteger maxVerse = 0;
    
    __block CGRect minRelativeRect = CGRectZero;
    __block CGRect maxRelativeRect = CGRectZero;
    
    __block BOOL minIsAtStart = NO;
    __block BOOL maxIsAtEnd = NO;
    
    __block CGFloat rowHeight = 0;
    
    if (textView == nil) {
        minVerse = 1;
        maxVerse = 1;
        minIsAtStart = YES;
        rowHeight = 10;
    }
    
    // Go through and find the longest minimum verse and the longest maximum verse
    [as enumerateAttributesInRange:NSMakeRange(0, as.length) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        NSString *verse = attrs[USFM_VERSE_NUMBER];
        if (verse) {
            CGRect textFrame = [self frameOfTextRange:range inTextView:textView];
            rowHeight = fmax(rowHeight, textFrame.size.height);
            
            NSInteger number = verse.integerValue;
            
            if ( minVerse >= number && textFrame.size.width > 10 && range.length > 5) { // Prevent return characters from causing an issue.
                CGRect fullRect = [self fullFrameOfVerse:number inTextView:textView];
                minRelativeRect = fullRect;
                if ( textView.contentOffset.y < 5.0 ) { // 5 = wiggle room
                    minIsAtStart = YES;
                }
                minVerse = number;
            }
            if (maxVerse < number || maxVerse == number) {
                maxVerse = number;
                maxRelativeRect = [self fullFrameOfVerse:number inTextView:textView];
                if ( (textView.contentOffset.y + textView.frame.size.height) > (textView.contentSize.height - 10) ) { // 10 = wiggle room
                    maxIsAtEnd = YES;
                }
            }
        }
    }];
    
    VerseContainer container;
    
    container.min = minVerse;
    container.minIsAtStart = minIsAtStart;
    container.minRectRelativeToScreenPosition = minRelativeRect;
    
    container.max = maxVerse;
    container.maxIsAtEnd = maxIsAtEnd;
    container.maxRectRelativeToScreenPosition = maxRelativeRect;
    
    container.rowHeight = rowHeight;
    
    return container;
}

- (CGRect)fullFrameOfVerse:(NSInteger)verseNumber inTextView:(UITextView *)textView
{
    __block CGRect frame = CGRectZero;
    frame.origin.x = CGFLOAT_MAX;
    frame.origin.y = CGFLOAT_MAX;
    
    [textView.attributedText enumerateAttributesInRange:NSMakeRange(0, textView.attributedText.length) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        NSString *verse = attrs[USFM_VERSE_NUMBER];
        if (verse) {
            NSInteger number = verse.integerValue;
            if ( verseNumber == number) {
                CGRect unadjustedFrame = [self unadjustedFrameOfTextRange:range inTextView:textView];
                unadjustedFrame.origin.y -= textView.contentOffset.y;
                
                frame.origin.x = fmin(frame.origin.x, unadjustedFrame.origin.x);
                frame.origin.y = fmin(frame.origin.y, unadjustedFrame.origin.y);
                CGFloat currentHeight = (unadjustedFrame.origin.y - frame.origin.y) + unadjustedFrame.size.height;
                frame.size.height = fmax(frame.size.height, currentHeight);
                frame.size.width = fmax(frame.size.width, unadjustedFrame.size.width);
            }
        }
    }];
    return frame;
}

- (CGRect)frameOfTextRange:(NSRange)range inTextView:(UITextView *)textView {
    textView.selectedRange = range;
    UITextRange *textRange = [textView selectedTextRange];
    CGRect rect = [textView firstRectForRange:textRange];
    textView.selectedTextRange = nil;
    return rect;
}

- (CGRect)unadjustedFrameOfTextRange:(NSRange)range inTextView:(UITextView *)textView {
    textView.selectedRange = range;
    UITextRange *textRange = [textView selectedTextRange];
    
    CGRect finalRect = CGRectZero;
    NSArray *selectRects = [textView selectionRectsForRange:textRange];
    
    BOOL isSetOnce = NO;
    for (UITextSelectionRect *textSelRect in selectRects) {
        CGRect foundRect = textSelRect.rect;
        if (isSetOnce == NO) {
            finalRect = foundRect;
            isSetOnce = YES;
        }
        else {
            finalRect.origin.x = fmin(finalRect.origin.x, foundRect.origin.x);
            finalRect.origin.y = fmin(finalRect.origin.y, finalRect.origin.y);
            CGFloat endY = foundRect.size.height + (foundRect.origin.y - finalRect.origin.y);
            finalRect.size.height = fmax(finalRect.size.height, endY);
            finalRect.size.width = fmax(finalRect.size.width, foundRect.size.width);
        }
    }
    return finalRect;
}


/// Returns the index of the current showing chapter.
- (NSInteger)currentIndex {
    CGPoint currentOffset = self.collectionView.contentOffset;
    return (int)currentOffset.x / (self.collectionView.bounds.size.width);
}


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
