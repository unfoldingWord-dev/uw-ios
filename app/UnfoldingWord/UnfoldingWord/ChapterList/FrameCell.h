//
//  FrameCell.h
//  UnfoldingWord
//
//  Created by Acts Media Inc. on 02/12/14.
//  Copyright (c) 2014 Distant Shores Media All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FrameCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *frame_contentLabel;
@property (nonatomic, weak) IBOutlet UIView *viewTextBackground;

- (void)setFrameImage:(UIImage *)image;

@end
