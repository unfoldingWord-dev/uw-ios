//
//  FrameDetailsViewController.m
//  UnfoldingWord
//
//  Created by Acts Media Inc. on 02/12/14.
//  Copyright (c) 2014 Distant Shores Media All rights reserved.
//

#import "FrameDetailsViewController.h"
#import "FrameCell.h"
#import "DWImageGetter.h"
#import "UWCoreDataClasses.h"
#import "FPPopoverController.h"
#import "ACTLabelButton.h"
#import "UFWSelectionTracker.h"
#import "LanguageInfoController.h"
#import "UFWNextChapterCell.h"
#import "UFWLanguagePickerVC.h"
#import "ChapterListTableViewController.h"
#import "EmptyCell.h"
#import "UFWStatusInfoViewController.h"
#import "UFWInfoView.h"
#import "ACTLabelButton.h"
#import "Constants.h"
#import "NSString+Trim.h"

static NSString *const kMatchVersion = @"version";
static NSString *const kMatchChapter = @"chapter";

@interface FrameDetailsViewController () <UIGestureRecognizerDelegate, ACTLabelButtonDelegate>
@property (nonatomic, strong) OpenChapter *chapter;

@property (nonatomic, strong) FPPopoverController *customPopoverController;
@property (nonatomic, strong) ACTLabelButton *buttonNavItem;

@property (nonatomic, assign) UIInterfaceOrientation lastOrientation;
@property (nonatomic, strong) NSArray *arrayOfFrames;

@property (nonatomic, strong) NSString *cellIDFrame;
@property (nonatomic, strong) NSString *cellIDNextChapter;
@property (nonatomic, strong) NSString *cellIdEmpty;

@property (nonatomic, assign) BOOL didShowPicker;
@end

@implementation FrameDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self addTapGestureRecognizer];
    
    [self loadNibsForCollectionView];
    
    self.collectionView.pagingEnabled = YES;
    
    UWTOC *toc = [UFWSelectionTracker TOCforJSON];
    OpenChapter *chapter = [toc chapterForNumber:[UFWSelectionTracker chapterNumberJSON]];
    [self setChapter:chapter];
    
    [self createRightNavButtons];
}

- (void)loadNibsForCollectionView
{
    self.cellIDFrame = NSStringFromClass([FrameCell class]);
    UINib *frameNib = [UINib nibWithNibName:self.cellIDFrame bundle:nil];
    [self.collectionView registerNib:frameNib forCellWithReuseIdentifier:self.cellIDFrame];
    
    self.cellIDNextChapter = NSStringFromClass([UFWNextChapterCell class]);
    UINib *nextNib = [UINib nibWithNibName:self.cellIDNextChapter bundle:nil];
    [self.collectionView registerNib:nextNib forCellWithReuseIdentifier:self.cellIDNextChapter];
    
    self.cellIdEmpty = NSStringFromClass([EmptyCell class]);
    UINib *emptyNib = [UINib nibWithNibName:self.cellIdEmpty bundle:nil];
    [self.collectionView registerNib:emptyNib forCellWithReuseIdentifier:self.cellIdEmpty];
}

- (void)createRightNavButtons
{
    // Add bar button items
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
    [buttonStatus setImage:[UFWInfoView imageReverseForStatus:self.chapter.container.toc.version.status] forState:UIControlStateNormal];
    [buttonStatus addTarget:self action:@selector(showPopOverStatusInfo:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *bbiStatus = [[UIBarButtonItem alloc] initWithCustomView:buttonStatus];
    
    self.navigationItem.rightBarButtonItems = @[bbiVersion, bbiStatus];
}

- (void)updateNavTitle
{
    ACTLabelButton *labelButton = [[ACTLabelButton alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    labelButton.font = FONT_MEDIUM;
    labelButton.text = self.chapter.title;
    CGFloat width = [labelButton.text widthUsingFont:labelButton.font] + [ACTLabelButton widthForArrow];
    labelButton.frame = CGRectMake(0, 0, width, 28);
    labelButton.delegate = self;
    labelButton.direction = ArrowDirectionDown;
    labelButton.colorNormal = [UIColor whiteColor];
    labelButton.colorHover = [UIColor lightGrayColor];
    labelButton.matchingObject = kMatchChapter;
    labelButton.userInteractionEnabled = YES;
    self.navigationItem.titleView = labelButton;
}

- (void)setChapter:(OpenChapter *)chapter
{
    _chapter = chapter;
    self.arrayOfFrames = [chapter sortedFrames];
    [self updateNavTitle];
    [self.collectionView reloadData];
}

- (void)labelButtonPressed:(ACTLabelButton *)labelButton;
{
    NSString *matchingObject = labelButton.matchingObject;
    if ([matchingObject isKindOfClass:[NSString class]]) {
        if ([matchingObject isEqualToString:kMatchVersion]) {
            [self userRequestedLanguageSelector:labelButton];
        }
        else if ([matchingObject isEqualToString:kMatchChapter]) {
            [self userRequestedBookPicker:labelButton];
        }
    }
    else {
        NSAssert2(NO, @"%s: matching object %@ not recognized!", __PRETTY_FUNCTION__, matchingObject);
    }
}

#pragma mark - Version Info Popover

- (void)showPopOverStatusInfo:(id)sender
{
    UFWStatusInfoViewController *statusVC = [[UFWStatusInfoViewController alloc] init];
    statusVC.status = self.chapter.container.toc.version.status;
    CGFloat width = fmin((self.view.frame.size.width - 40), 530);
    CGSize size = [UFWInfoView sizeForStatus:statusVC.status forWidth:width withDeleteButton:NO];
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

#pragma mark - Chapter Picker
- (void)userRequestedBookPicker:(id)sender
{
    __weak typeof(self) weakself = self;
    UIViewController *navVC = [ChapterListTableViewController navigationChapterPickerWithTopContainer:self.chapter.container.toc.version.language.topContainer completion:^(BOOL isCanceled, OpenChapter *selectedChapter) {
        if (isCanceled == NO && selectedChapter != nil) {
            [weakself setChapter:selectedChapter];
        }
        [weakself dismissViewControllerAnimated:YES completion:^{}];
    }];
    [self presentViewController:navVC animated:YES completion:^{}];
}


#pragma mark - Language Picker
- (void)userRequestedLanguageSelector:(id)sender
{
    __weak typeof(self) weakself = self;
    UIViewController *navVC = [UFWLanguagePickerVC navigationLanguagePickerWithTopContainer:self.topContainer completion:^(BOOL isCanceled, UWVersion *versionPicked) {
        [weakself dismissViewControllerAnimated:YES completion:^{}];
        
        if (isCanceled) {
            return;
        }
        
        if (versionPicked.toc.allObjects.count == 0) {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"There is no content for the selected version.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss", nil) otherButtonTitles: nil] show];
            return;
        }
        
        // Select the TOC
        UWTOC *existingTOC = weakself.chapter.container.toc;
        UWTOC *selectedTOC = nil;
        if (existingTOC == nil) {
            selectedTOC = [versionPicked sortedTOCs][0];
        }
        else {
            BOOL success = NO;
            for (UWTOC *toc in versionPicked.toc) {
                if ([toc.slug isKindOfClass:[NSString class]] == NO) {
                    NSAssert2(NO, @"%s: The toc did not have a slug. No way to track it: %@", __PRETTY_FUNCTION__, toc);
                    continue;
                }
                if ([existingTOC.slug isEqualToString:toc.slug]) {
                    selectedTOC = toc;
                    break;
                }
            }
            if (success == NO) { // No slug matches
                selectedTOC = [versionPicked sortedTOCs][0];
            }
        }
        // End select toc
        
        
        // Select the chapter
        if (selectedTOC.openContainer.chapters.count == 0) { // handle unexpected error.
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:@"No chapters for your selection." delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss", nil) otherButtonTitles: nil] show];
            return;
        }
        
        OpenChapter *selectedChapter = [selectedTOC.openContainer sortedChapters][0];
        // Override the selected chapter if we have open that matches an existing chapter
        for (OpenChapter *aChapter in selectedTOC.openContainer.chapters.allObjects) {
            if (aChapter.number.integerValue == [UFWSelectionTracker chapterNumberJSON]) {
                selectedChapter = aChapter;
                break;
            }
        }
        // End select chapter
        
        
        // Select the frame
        if (selectedChapter.frames.count == 0) { // handle unexpected error.
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:@"No frames for your selection." delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss", nil) otherButtonTitles: nil] show];
            return;
        }
        
        NSInteger frameIndex = [UFWSelectionTracker frameNumberJSON];
        NSArray *frames = [selectedChapter sortedFrames];
        if (frameIndex >= frames.count) {
            frameIndex = 0;
        }
        // End select frame
        
        // Save the selections
        [UFWSelectionTracker setJSONTOC:selectedTOC];
        [UFWSelectionTracker setChapterJSON:selectedChapter.number.integerValue];
        [UFWSelectionTracker setFrameJSON:frameIndex];
        
        weakself.chapter = selectedChapter;
        [weakself.collectionView reloadData];
        [weakself jumpToCurrentFrameAnimated:NO];
        
        [weakself createRightNavButtons];
        
    }];
    
    [self presentViewController:navVC animated:YES completion:^{}];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ( [self checkForRotationChange] == YES) {
        [self.collectionView reloadData];
    }
    [self jumpToCurrentFrameAnimated:YES];

}

- (void)jumpToCurrentFrameAnimated:(BOOL)animated
{
    NSInteger chapterNumber = self.chapter.number.integerValue;
    NSInteger selectedChapter = [UFWSelectionTracker chapterNumberJSON];

    if ( chapterNumber != selectedChapter) {
        return;
    }
    
    NSInteger currentFrame = [UFWSelectionTracker frameNumberJSON];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:currentFrame inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:animated];
}

#pragma mark - Tap Gesture Hide Nav Bar

- (void)addTapGestureRecognizer
{
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
    tapRecognizer.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:tapRecognizer];
}

- (void)tapRecognized:(UITapGestureRecognizer *)tapRecognizer
{
//    // If we're in portrait mode, then ignore.
//    if (self.view.bounds.size.width < self.view.bounds.size.height && ! self.navigationController.navigationBarHidden) {
//        return;
//    }

    [self showOrHideNavigationBarAnimated:YES];
    [self.collectionViewLayout invalidateLayout];
}

- (void)showOrHideNavigationBarAnimated:(BOOL)animated
{
    BOOL hide = (self.navigationController.navigationBarHidden) ? NO : YES;
    [self.navigationController setNavigationBarHidden:hide animated:animated];
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.chapter.frames.count == 0) {
        return 1;
    }
    
    NSArray *chaptersArray = [self.chapter.container.chapters.allObjects sortedArrayUsingComparator:^NSComparisonResult(OpenChapter *chap1, OpenChapter *chap2) {
        return [chap1.number compare:chap2.number];
    }];
    OpenChapter *lastChapter = nil;
    
    if (chaptersArray.count > 0) {
        lastChapter = [chaptersArray lastObject];
    }
    
    //If last chapter, there is no next chapter cell; otherwise add one.
    if ([self.chapter isEqual:lastChapter]) {
        return self.arrayOfFrames.count;
    }
    else {
        return self.arrayOfFrames.count + 1;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.collectionView.frame.size;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.chapter.frames.count == 0) { // nothing loaded
        EmptyCell *emptyCell = [collectionView dequeueReusableCellWithReuseIdentifier:self.cellIdEmpty forIndexPath:indexPath];
        return emptyCell;
    }
    else if ([self.arrayOfFrames count] == indexPath.row) // We passed the last frame
    {
        UFWNextChapterCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.cellIDNextChapter forIndexPath:indexPath];
        [cell.buttonNextChapter setTitle:NSLocalizedString(@"nextChapter", nil) forState:UIControlStateNormal];
        if (cell.buttonNextChapter.allTargets.count == 0) {
            [cell.buttonNextChapter addTarget:self action:@selector(onNextChapterTouched:) forControlEvents:UIControlEventTouchUpInside];
        }
        return cell;
    }
    else // we're on a regular frame
    {
        FrameCell *cell =[collectionView dequeueReusableCellWithReuseIdentifier:self.cellIDFrame forIndexPath:indexPath];
        OpenFrame *frame = self.arrayOfFrames[indexPath.row];
        cell.frame_contentLabel.text = frame.text;
        cell.frame_contentLabel.textAlignment = [LanguageInfoController textAlignmentForLanguageCode:self.chapter.container.toc.version.language.lc];
         [cell setFrameImage:nil];
        
        __weak typeof(self) weakself = self;
        [[DWImageGetter sharedInstance] retrieveImageWithURLString:frame.imageUrl completionBlock:^(NSString *originalUrl, UIImage *image) {
            // Must double check that the image hasn't been recycled for a different chapter
            NSIndexPath *currentIP = [weakself.collectionView indexPathForCell:cell];
            OpenFrame *currentFrame = [weakself.arrayOfFrames objectAtIndex:currentIP.row];
            if ([currentFrame.imageUrl isEqualToString:originalUrl]) {
                [cell setFrameImage:image];
            }
        }];
        return cell;
    }
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

//    // Always show the navigation bar in portrait mode.
//    if (UIDeviceOrientationIsPortrait(toInterfaceOrientation) && self.navigationController.navigationBarHidden) {
//        [self showOrHideNavigationBarAnimated:YES];
//    }
    
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
    CGFloat offsetIndex = (int)currentOffset.x / (self.view.bounds.size.width);
    CGFloat newOffsetX = offsetIndex * (height);
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

#pragma mark <UICollectionViewDelegate>

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self resetChapterFrame];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ( ! decelerate) {
        [self resetChapterFrame];
    }
}

- (void)resetChapterFrame
{
    CGPoint currentOffset = self.collectionView.contentOffset;
    NSInteger index = (int)currentOffset.x / (self.view.bounds.size.width);
    [UFWSelectionTracker setFrameJSON:index];
    [self updateNavTitle];
}

#pragma mark - Methods to prevent the back gesture

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Disable iOS 7 back gesture
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
    
    if (self.chapter.frames.count == 0 && self.didShowPicker == NO) {
        self.didShowPicker = YES;
        [self userRequestedLanguageSelector:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Enable iOS 7 back gesture
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return NO;
}


#pragma mark - NextChapter Methods

-(void)onNextChapterTouched:(id)sender
{
    NSArray *chaptersArray = [self.chapter.container.chapters.allObjects sortedArrayUsingComparator:^NSComparisonResult(OpenChapter *chap1, OpenChapter *chap2) {
        return [chap1.number compare:chap2.number];
    }];
    
    OpenChapter *nextChapter = nil;
    NSInteger chapterNumber = 0;
    for (int i = 0; i < chaptersArray.count ; i++) {
        OpenChapter *chapter = chaptersArray[i];
        if ([chapter isEqual:self.chapter] && (i+1) < chaptersArray.count) {
            NSInteger nextChapterIndex = i+1;
            nextChapter = chaptersArray[nextChapterIndex];
            chapterNumber = nextChapterIndex+1;
            break;
        }
    }
    
    if ( ! nextChapter) {
        NSAssert3(nextChapter, @"%s: Could not find next chapter in array %@ with chapter %@", __PRETTY_FUNCTION__, chaptersArray, self.chapter);
        return;
    }
    
    self.chapter = nextChapter;
    [UFWSelectionTracker setChapterJSON:chapterNumber];
    [UFWSelectionTracker setFrameJSON:0];
    
    NSIndexPath *nextIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    
    [self.collectionView scrollToItemAtIndexPath:nextIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    
    CGRect cFrame = self.collectionView.frame;
    [self.collectionView setFrame:CGRectMake(cFrame.size.width,cFrame.origin.y,cFrame.size.width, cFrame.size.height)];
    
    [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction animations:^{
        [self.collectionView setFrame:cFrame];
    } completion:^(BOOL finished){
        [self.collectionView reloadData];
        // do whatever post processing you want (such as resetting what is "current" and what is "next")
    }];
    
}

@end
