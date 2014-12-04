//
//  FrameDetailsViewController.m
//  UnfoldingWord
//
//  Created by Acts Media Inc. on 02/12/14.
//  Copyright (c) 2014 Distant Shores Media All rights reserved.
//

#import "FrameDetailsViewController.h"
#import "FrameCell.h"
#import "FrameModel.h"
#import "UIImageView+AFNetworking.h"

@interface FrameDetailsViewController () <UIGestureRecognizerDelegate>
@property (nonatomic, assign) UIInterfaceOrientation lastOrientation;
@end

@implementation FrameDetailsViewController

static NSString * const reuseIdentifier = @"FrameCellID";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
//    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)    name:UIDeviceOrientationDidChangeNotification  object:nil];

    
    // Uncomment the following line to preserve selection between presentations
//     self.clearsSelectionOnViewWillAppear = NO;
//    [self.collectionView setContentInset:UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height+self.navigationController.navigationBar.frame.origin.y, 0, 0, 0)];
//    self.automaticallyAdjustsScrollViewInsets = YES;
//
//    // Register cell classe

    
    // Do any additional setup after loading the view.
}



- (void)orientationChanged:(NSNotification *)notification
{
//    [self.collectionView setContentInset:UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height+self.navigationController.navigationBar.frame.origin.y, 0, 0, 0)];

//    [self.collectionView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.frameList count];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.collectionView.frame.size;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FrameCell *cell =[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    FrameModel *frame = [self.frameList objectAtIndex:indexPath.row];
    
    [cell.frame_Image setImageWithURL:[NSURL URLWithString:frame.frame_image] placeholderImage:[UIImage imageNamed:[frame.frame_image lastPathComponent]]];
    
    cell.frame_contentLabel.text = frame.frame_text;

    return cell;
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
    [UIView animateWithDuration:duration delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self.collectionView setContentOffset:newOffset];
    } completion:^(BOOL finished) {
        [self.collectionView setContentOffset:newOffset];
    }];
    [self.collectionView reloadData];
    
    self.lastOrientation = toInterfaceOrientation;
}

#pragma mark <UICollectionViewDelegate>

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

@end
