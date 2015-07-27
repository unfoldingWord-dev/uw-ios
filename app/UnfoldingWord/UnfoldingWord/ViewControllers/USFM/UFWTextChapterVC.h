//
//  UFWTextChapterVC.h
//  UnfoldingWord
//
//  Created by David Solberg on 5/6/15.
//

#import <UIKit/UIKit.h>
#import "VerseContainer.h"

@class UWTopContainer, UWTOC;
@protocol USFMPanelDelegate;

@interface UFWTextChapterVC : UIViewController

@property (nonatomic, strong)  UWTopContainer* __nullable topContainer;
@property (nonatomic, assign) BOOL isSideTOC;
@property (nonatomic, weak) id <USFMPanelDelegate> __nullable delegate;
@property (nonatomic, assign) BOOL isActive;

- (void)scrollCollectionView:(CGFloat)offset;
- (void)scrollTextView:(CGFloat)offset;
- (void)adjustTextViewWithVerses:(VerseContainer)verses;
- (void)changeToMatchingTOC:(UWTOC* __nullable)toc;

- (void) changeToSize:(CGSize)size;

@end
