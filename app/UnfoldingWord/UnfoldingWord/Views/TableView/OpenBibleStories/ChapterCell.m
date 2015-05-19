//
//  ChapterCell.m
//  UnfoldingWord
//
//  Created by Acts Media Inc. on 01/12/14.
//  Copyright (c) 2014 Distant Shores Media All rights reserved.
//

#import "ChapterCell.h"

static CGFloat const kDefaultHeight = 89;

@implementation ChapterCell

+ (CGFloat)estimatedHeight
{
    return kDefaultHeight;
}

- (void)layoutSubviews
{
    [self adjustMultiLineLabel:self.chapter_titleLabel];
    [self adjustMultiLineLabel:self.chapter_detailLabel];
    
    [super layoutSubviews];
}

- (void)adjustMultiLineLabel:(UILabel *)label
{
    [label setNeedsUpdateConstraints];
    [label setNeedsLayout];
    [label layoutIfNeeded];
    label.preferredMaxLayoutWidth = label.frame.size.width;
    [label setNeedsUpdateConstraints];
    [label setNeedsLayout];
    [label layoutIfNeeded];
}

- (CGFloat)calculatedHeight
{
    CGRect maxRect = self.frame;
    maxRect.size.height = 100000;
    self.frame = maxRect;
    [self layoutIfNeeded];
    
    [self adjustMultiLineLabel:self.chapter_titleLabel];
    [self adjustMultiLineLabel:self.chapter_detailLabel];
    CGFloat chapterHeight = self.chapter_titleLabel.frame.size.height;
    CGFloat detailHeight = self.chapter_detailLabel.frame.size.height;
    CGFloat bufferArea = 16;
    CGFloat totalHeight = chapterHeight + detailHeight + bufferArea;
    
    return fmax(totalHeight, kDefaultHeight);
}

@end
