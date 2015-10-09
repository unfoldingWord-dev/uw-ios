////
////  UFWTextChapterVC.h
////  UnfoldingWord
////
////  Created by David Solberg on 5/6/15.
////
//
//#import <UIKit/UIKit.h>
//#import "VerseContainer.h"
//
//@class UWTopContainer, UWTOC, USFMTextLocationInfo;
//@protocol USFMPanelDelegate;
//
//@interface UFWTextChapterVC : UIViewController
//
//@property (nonatomic, strong)  UWTopContainer* __nullable topContainer;
//@property (nonatomic, assign) BOOL isSideTOC;
//@property (nonatomic, weak) id <USFMPanelDelegate> __nullable delegate;
//@property (nonatomic, assign) BOOL isActive;
//@property (nonatomic, readonly) BOOL isSettingUp;
//
//@property (nonatomic, readonly, strong) UWTOC* __nullable currentToc;
//@property (nonatomic, readonly, assign) NSInteger currentChapterIndex;
//
//- (void)scrollCollectionView:(CGFloat)offset;
//- (void)scrollTextView:(CGFloat)offset;
//- (void)adjustTextViewWithVerses:(VerseContainer)remoteVerses animationDuration:(CGFloat)duration;
//- (void)changeToMatchingTOC:(UWTOC* __nullable)toc;
//- (void)matchingCollectionViewDidFinishScrolling;
//- (void)bookButtonPressed;
//- (void) changeToSize:(CGSize)size;
//- (void)updateVersionTitle;
//
//- (void)animateToNextTOC;
//
///// returns a verse container that describes the verses currently visible in the textview.
//- (VerseContainer)versesVisible;
//
//- (USFMTextLocationInfo * __nonnull)currentTextLocation;
//- (void)scrollToLocation:(USFMTextLocationInfo *__nonnull)location animated:(BOOL)animated;
//
//- (void)willSetup;
//- (void)didSetup;
//
//@end
