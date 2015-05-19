//
//  UFWBaseSettingsCell.m
//  UnfoldingWord
//
//  Created by David Solberg on 5/14/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

#import "UFWBaseSettingsCell.h"
#import "Constants.h"

@implementation UFWBaseSettingsCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.labelSettings.text = NSLocalizedString(@"Settings", nil);
    self.labelSettings.textColor = [UIColor whiteColor];
    self.labelSettings.font = FONT_MEDIUM;
    
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
}

@end
