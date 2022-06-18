//
//  UFWTopLevelItemCell.m
//  UnfoldingWord
//
//  Created by David Solberg on 5/6/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

#import "UFWTopLevelItemCell.h"
#import "Constants.h"

@implementation UFWTopLevelItemCell

- (void)awakeFromNib {
    self.labelName.textColor = TEXT_COLOR_NORMAL;
    self.labelName.font = FONT_MEDIUM;
    [super awakeFromNib];
}

@end
