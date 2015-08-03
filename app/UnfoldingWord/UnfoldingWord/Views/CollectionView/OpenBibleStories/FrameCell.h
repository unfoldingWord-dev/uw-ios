//
//  FrameCell.h
//  UnfoldingWord
//

#import <UIKit/UIKit.h>
#import "FrameCellDelegate.h"

@interface FrameCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UILabel *label_contentMain;
@property (nonatomic, weak) IBOutlet UILabel *label_contentSide;


@property (nonatomic, weak) id <FrameCellDelegate> delegate;

- (void)setVersionName:(NSString *)name isSide:(BOOL)isSide;
- (void)setStatusImage:(UIImage *)image isSide:(BOOL)isSide;

- (void)setFrameImage:(UIImage *)image;

- (void)setIsShowingSide:(BOOL)isShowingSide animated:(BOOL)animated;

@end
