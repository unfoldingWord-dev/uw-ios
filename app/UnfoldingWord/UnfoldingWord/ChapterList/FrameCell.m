//
//  FrameCell.m
//  UnfoldingWord
//
//  Created by Acts Media Inc. on 02/12/14.
//  Copyright (c) 2014 Distant Shores Media All rights reserved.
//

#import "FrameCell.h"
#import "Constants.h"

@implementation FrameCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self adjustColors];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self adjustColors];
        // change to our custom selected background view
    }
    return self;
}

- (void)adjustColors
{
    self.backgroundColor = TABBAR_COLOR;
    self.viewTextBackground.backgroundColor = TABBAR_COLOR_TRANSPARENT;
}

@end
