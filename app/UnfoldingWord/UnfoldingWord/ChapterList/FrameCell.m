//
//  FrameCell.m
//  UnfoldingWord
//
//  Created by Acts Media Inc. on 02/12/14.
//  Copyright (c) 2014 Distant Shores Media All rights reserved.
//

#import "FrameCell.h"
#import "Constants.h"

@interface FrameCell ()
@property (weak, nonatomic) IBOutlet UIImageView *frame_Image;
@property (nonatomic, strong) NSLayoutConstraint *constraintImageRatio;
@end

@implementation FrameCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self adjustColors];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self adjustColors];
    }
    return self;
}

- (void)adjustColors
{
    self.backgroundColor = TABBAR_COLOR;
    self.viewTextBackground.backgroundColor = TABBAR_COLOR_TRANSPARENT;
}

- (void)setFrameImage:(UIImage *)image
{
    if ( ! image) {
        self.frame_Image.image = nil;
        return;
    }
    
    CGFloat ratio = image.size.width / image.size.height;
    NSLayoutConstraint *ratioConstraint = [NSLayoutConstraint constraintWithItem:self.frame_Image attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.frame_Image attribute:NSLayoutAttributeHeight multiplier:ratio constant:1.0];
    [self.contentView addConstraint:ratioConstraint];
    [self.contentView removeConstraint:self.constraintImageRatio];
    self.constraintImageRatio = ratioConstraint;
    self.frame_Image.image = image;
}


@end
