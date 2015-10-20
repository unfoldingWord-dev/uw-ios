//
//  FrameCell.h
//  UnfoldingWord
//

#import <UIKit/UIKit.h>
#import "FrameCellDelegate.h"

@interface FrameCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UITextView *textView_contentMain;
@property (nonatomic, weak) IBOutlet UITextView *textView_contentSide;

@property (nonatomic, weak) id <FrameCellDelegate> delegate;

//- (void)setVersionName:(NSString *)name isSide:(BOOL)isSide;

//- (void)setStatusImage:(UIImage *)image isSide:(BOOL)isSide;

- (void)setFrameImage:(UIImage *)image;

/// Shows or hides the diglot side view. Set animated to yes to show a somewhat rough animation.
- (void)setIsShowingSide:(BOOL)isShowingSide animated:(BOOL)animated;

//- (void)setIsShowingFullScreen:(BOOL)isFullScreen animated:(BOOL)animated;

@end
