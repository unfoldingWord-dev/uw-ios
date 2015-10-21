//
//  FrameDetailsViewController.h
//  UnfoldingWord
//
//  Created by Acts Media Inc. on 02/12/14.
//  Copyright (c) 2014 Distant Shores Media All rights reserved.
//

#import <UIKit/UIKit.h>
@class UWTopContainer, FakeNavBarView, UWTOC, ContainerVC, OpenChapter;

@interface FrameDetailsViewController : UICollectionViewController

@property (nonatomic, strong) UWTopContainer *topContainer;
@property (nonatomic, weak) FakeNavBarView *fakeNavBar;

@property (nonatomic, weak) ContainerVC *containerVC;

- (void)processTOCPicked:(UWTOC *)selectedTOC isSide:(BOOL)isSide;

- (void)resetMainChapter:(OpenChapter *)mainChapter sideChapter:(OpenChapter *)sideChapter;

- (void)addMasterContainerBlocksToContainer:(ContainerVC *)masterContainer;

- (UWTOC *)tocFromIsSide:(BOOL)isSide;

- (void)jumpToCurrentFrameAnimated:(BOOL)animated;

- (void)changeDiglotToShowing:(BOOL)isShowing;

@end
