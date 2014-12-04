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

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
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
    
    [self adjustMultiLineLabel:self.chapter_titleLabel];
    [self adjustMultiLineLabel:self.chapter_detailLabel];
    CGFloat chapterHeight = self.chapter_titleLabel.frame.size.height;
    CGFloat detailHeight = self.chapter_detailLabel.frame.size.height;
    CGFloat bufferArea = 16;
    CGFloat totalHeight = chapterHeight + detailHeight + bufferArea;
    
    NSLog(@"height = %.0f; %@", totalHeight, [self description]);
    return fmax(totalHeight, kDefaultHeight);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"\ntitle: %@\ndetail:%@\n\nDetail size %@", self.chapter_titleLabel.text, self.chapter_detailLabel.text, NSStringFromCGSize(self.chapter_detailLabel.frame.size)];
}

@end
