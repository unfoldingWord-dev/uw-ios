//
//  LanguageCell.h
//  UnfoldingWord
//
//  Created by Acts Media Inc. on 25/11/14.
//  Copyright (c) 2014 Distant Shores Media All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LanguageCell : UITableViewCell
{
}

@property (nonatomic, weak) IBOutlet UILabel *languageLabel;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *detailTextViewConstraint;
@property (nonatomic, weak) IBOutlet UIImageView *levelImageView;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;
@property (weak, nonatomic) IBOutlet UILabel *detailTextView;

@end
