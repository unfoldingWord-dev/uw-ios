//
//  FrameDetailsViewController.m
//  UnfoldingWord
//
//  Created by Acts Media Inc. on 02/12/14.
//  Copyright (c) 2014 Distant Shores Media All rights reserved.
//

#import "FrameDetailsViewController.h"
#import "FrameCell.h"
#import "UIImageView+AFNetworking.h"
#import "DWImageGetter.h"
#import "CoreDataClasses.h"
#import "UFWLanguagesController.h"
#import "FPPopoverController.h"
#import "UFWLanguageListPickerVC.h"
#import "ACTLabelButton.h"

@interface FrameDetailsViewController () <UIGestureRecognizerDelegate, ACTLabelButtonDelegate>
@property (nonatomic, strong) FPPopoverController *customPopoverController;
@property (nonatomic, strong) UFWLanguagesController *languagesController;
@property (nonatomic, strong) ACTLabelButton *buttonNavItem;

@property (nonatomic, assign) UIInterfaceOrientation lastOrientation;
@property (nonatomic, strong) NSArray *frames;
@end

@implementation FrameDetailsViewController

static NSString * const reuseIdentifier = @"FrameCellID";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createNavButton];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self addTapGestureRecognizer];
}

- (void)setChapter:(UFWChapter *)chapter
{
    _chapter = chapter;
    self.frames = [_chapter sortedFrames];
    self.navigationItem.title = _chapter.title;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.languagesController = [UFWLanguagesController new];
    [self resetRightNavButton];
    [self jumpToCurrentFrameAnimated:YES];
}

- (void)createNavButton
{
    ACTLabelButton *navButton = [[ACTLabelButton alloc] init];
    navButton.font = [UIFont boldSystemFontOfSize:17];
    navButton.colorNormal = [UIColor whiteColor];
    navButton.colorHover = [UIColor lightGrayColor];
    navButton.direction = ArrowDirectionDown;
    navButton.delegate = self;
    navButton.userInteractionEnabled = YES;
    self.buttonNavItem = navButton;
}

- (void)resetRightNavButton
{
    NSString *slug = self.languagesController.currentLanguageSlug;
    NSString *languageName = [self.languagesController languageNameForLanguageSlug:slug];
    
    self.navigationItem.rightBarButtonItem = nil;
    self.buttonNavItem.text = languageName;
    CGRect frame = CGRectZero;
    frame.size = [self.buttonNavItem intrinsicContentSize];
    self.buttonNavItem.frame = frame;
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.buttonNavItem];
    self.navigationItem.rightBarButtonItem = barButtonItem;
}

- (void)labelButtonPressed:(ACTLabelButton *)labelButton
{
    [self showLanguageListFromView:labelButton];
}

- (void)showLanguageListFromView:(UIView *)view
{
    NSArray *languageSlugs = [self.languagesController arrayLanguageSlugsForProject:self.chapter.bible.language.projectLanguage.project];
    NSString *projectInfo = [self.chapter.bible.language.projectLanguage.project projectNameForLanguageSlug:self.languagesController.currentLanguageSlug];
    projectInfo = [NSString stringWithFormat:@"for %@", projectInfo];
    UFWLanguageListPickerVC *languagePicker = [UFWLanguageListPickerVC pickLanguageVCForArrayOfLangSlugs:languageSlugs projectInfo:projectInfo completion:^(NSString *slugPicked) {
        if ( ! [self.languagesController.currentLanguageSlug isEqualToString:slugPicked]) {
            UFWBible *changedBible = [self.languagesController bibleMatchingBible:self.chapter.bible withNewLanguageSlug:slugPicked];
            
            if (changedBible != nil) {
                NSString *chapterNumber = self.chapter.number;
                UFWChapter *chapter = [changedBible chapterForNumberString:chapterNumber];
                if (chapter != nil) {
                        self.chapter = chapter;
                        self.frames = [chapter sortedFrames];
                        [self.languagesController setCurrentLanguageSlug:slugPicked];
                        [self resetRightNavButton];
                        [self.collectionView reloadData];
                }
             }
        }
        [self.customPopoverController dismissPopoverAnimated:YES];
    }];
    
    CGFloat requiredInset = 50;
    CGSize maxSize = [languagePicker completeContentSize];
    maxSize.height = fmin(maxSize.height, (self.view.frame.size.height - requiredInset));
    maxSize.width = fmin(maxSize.width, (self.view.frame.size.width - requiredInset));
    
    self.customPopoverController = [[FPPopoverController alloc] initWithViewController:languagePicker delegate:nil maxSize:maxSize];
    self.customPopoverController.border = NO;
    [self.customPopoverController setShadowsHidden:YES];
    if ([view isKindOfClass:[UIView class]]) {
        self.customPopoverController.arrowDirection = FPPopoverArrowDirectionAny;
        [self.customPopoverController presentPopoverFromView:view];
    }
    else {
        self.customPopoverController.arrowDirection = FPPopoverNoArrow;
        [self.customPopoverController presentPopoverFromView:self.view];
    }
}

- (void)jumpToCurrentFrameAnimated:(BOOL)animated
{
    if ( ! [self.chapter.bible.currentChapter isEqual:self.chapter] || ! self.chapter.bible.currentFrame ) {
        return;
    }
    
    UFWFrame *currentFrame = self.chapter.bible.currentFrame;
    if (currentFrame != nil) {
        for (int i = 0; i < [self.frames count]; i++) {
            UFWFrame *aFrame = self.frames[i];
            if ([aFrame isEqual:currentFrame]) {
                NSIndexPath *ip = [NSIndexPath indexPathForItem:i inSection:0];
                if (ip) {
                    [self.collectionView scrollToItemAtIndexPath:ip atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:animated];
                }
                break;
            }
        }
    }
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
    UFWChapter *lastChapter = [[self.chapter.bible sortedChapters] lastObject];
    
    //If last chapter, there is no next chapter cell; otherwise add one.
    if ([self.chapter isEqual:lastChapter]) {
        return self.frames.count;
    }
    else {
        return self.frames.count + 1;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.collectionView.frame.size;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if([self.frames count] == indexPath.row)
    {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FrameLastCellID" forIndexPath:indexPath];
        UIButton *nextChapterButton = (UIButton*)[cell viewWithTag:111];
        [nextChapterButton setTitle:NSLocalizedString(@"nextChapter", nil) forState:UIControlStateNormal];
        [nextChapterButton addTarget:self action:@selector(onNextChapterTouched:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    else
    {
        FrameCell *cell =[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
        UFWFrame *frame = self.frames[indexPath.row];
        cell.frame_contentLabel.text = frame.text;
        if ([frame.chapter.bible.language.projectLanguage direction] == DirectionLeftToRight) {
            cell.frame_contentLabel.textAlignment = NSTextAlignmentLeft;
        }
        else {
            cell.frame_contentLabel.textAlignment = NSTextAlignmentRight;
        }
        
        if (frame.imageUrl.length ==0) {
            UIImage *image = [UIImage imageNamed:@"placeholderFrameImage"];
            [cell setFrameImage:image];
        }
        else {
            [cell setFrameImage:nil];
            
            __weak typeof(self) weakself = self;
            [[DWImageGetter sharedInstance] retrieveImageWithURLString:frame.imageUrl completionBlock:^(NSString *originalUrl, UIImage *image) {
                // Must double check that the image hasn't been recycled for a different chapter
                NSIndexPath *currentIP = [weakself.collectionView indexPathForCell:cell];
                UFWFrame *currentFrame = [self.frames objectAtIndex:currentIP.row];
                if ([currentFrame.imageUrl isEqualToString:originalUrl]) {
                    [cell setFrameImage:image];
                }
            }];
        }
        return cell;
    }
    
}

#pragma mark - Rotation

-(void) willRotateToInterfaceOrientation: (UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
//    // Always show the navigation bar in portrait mode.
//    if (UIDeviceOrientationIsPortrait(toInterfaceOrientation) && self.navigationController.navigationBarHidden) {
//        [self showOrHideNavigationBarAnimated:YES];
//    }
    
    if (self.lastOrientation != 0) {
        if ( UIDeviceOrientationIsLandscape(self.lastOrientation) && UIDeviceOrientationIsLandscape(toInterfaceOrientation)) {
            return;
        }
        if ( UIDeviceOrientationIsPortrait(self.lastOrientation) && UIDeviceOrientationIsPortrait(toInterfaceOrientation)) {
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
    
    if (index < self.frames.count) {
        UFWFrame *frame = self.frames[index];
        self.chapter.bible.currentFrame = frame;
    }
}


/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

#pragma mark - Methods to prevent the back gesture

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Disable iOS 7 back gesture
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
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
    NSArray *chapters = [self.chapter.bible sortedChapters];
    
    UFWChapter *nextChapter = nil;
    for (int i = 0; i < chapters.count ; i++) {
        UFWChapter *chapter = chapters[i];
        if ([chapter isEqual:self.chapter] && (i+1) < chapters.count) {
            nextChapter = chapters[i+1];
            break;
        }
    }
    
    if ( ! nextChapter) {
        NSAssert3(nextChapter, @"%s: Could not find next chapter in array %@ with chapter %@", __PRETTY_FUNCTION__, chapters, self.chapter);
        return;
    }
    
    self.chapter = nextChapter;
    self.chapter.bible.currentChapter = nextChapter;
    self.chapter.bible.currentFrame = nil;
    
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    
    [self.collectionView scrollToItemAtIndexPath:newIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    
    CGRect cFrame = self.collectionView.frame;
    [self.collectionView setFrame:CGRectMake(cFrame.size.width,cFrame.origin.y,cFrame.size.width, cFrame.size.height)];
    
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         [self.collectionView setFrame:cFrame];
                     }
                     completion:^(BOOL finished){
                         [self.collectionView reloadData];
                         // do whatever post processing you want (such as resetting what is "current" and what is "next")
                     }];

}

@end
