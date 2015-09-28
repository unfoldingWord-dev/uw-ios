//
//  EmptyCell.m
//  UnfoldingWord
//
//  Created by David Solberg on 5/6/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

#import "EmptyCell.h"
#import "Constants.h"

@implementation EmptyCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.contentView.backgroundColor = BACKGROUND_GREEN;
    self.label.textColor = [UIColor whiteColor];
    self.label.font = FONT_MEDIUM;
    self.label.text = NSLocalizedString(@"You can download and select a item by tapping \"Add\" on the top bar.", nil);
}

@end
