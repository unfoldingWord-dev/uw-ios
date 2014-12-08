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

@interface FrameDetailsViewController () <UIGestureRecognizerDelegate>
@property (nonatomic, assign) UIInterfaceOrientation lastOrientation;
@property (nonatomic, strong) NSArray *frames;
@end

@implementation FrameDetailsViewController

static NSString * const reuseIdentifier = @"FrameCellID";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
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
    [self jumpToCurrentFrameAnimated:YES];
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


#pragma mark <UICollectionViewDataSource>

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
        [nextChapterButton setTitle:self.chapter.bible.next_chapter_string forState:UIControlStateNormal];
        [nextChapterButton addTarget:self action:@selector(onNextChapterTouched:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    else
    {
        FrameCell *cell =[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
        UFWFrame *frame = self.frames[indexPath.row];
        cell.frame_contentLabel.text = frame.text;
        cell.frame_Image.image = nil; // Don't want it to flash from a reused cell
        
        __weak typeof(self) weakself = self;
        [[DWImageGetter sharedInstance] retrieveImageWithURLString:frame.imageUrl completionBlock:^(NSString *originalUrl, UIImage *image) {
            // Must double check that the image hasn't been recycled for a different chapter
            NSIndexPath *currentIP = [weakself.collectionView indexPathForCell:cell];
            UFWFrame *currentFrame = [self.frames objectAtIndex:currentIP.row];
            if ([currentFrame.imageUrl isEqualToString:originalUrl]) {
                cell.frame_Image.image = image;
            }
        }];
        return cell;
    }
   
}

#pragma mark - Rotation

-(void) willRotateToInterfaceOrientation: (UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
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
