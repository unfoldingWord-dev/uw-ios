//
//  LanguageNameCell.m
//  UnfoldingWord
//
//  Created by David Solberg on 5/7/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

#import "UFWLanguageNameCell.h"
#import "Constants.h"
#import "ACTLabelButton.h"

@implementation UFWLanguageNameCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.labelButtonLanguageName.font = [FONT_MEDIUM fontWithSize:19];
}


@end
