//
//  ChapterCell.h
//  UnfoldingWord
//
//  Created by Acts Media Inc. on 01/12/14.
//  Copyright (c) 2014 Distant Shores Media All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChapterCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *chapter_detailLabel;
@property (weak, nonatomic) IBOutlet UILabel *chapter_titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *chapter_thumb;

- (CGFloat)calculatedHeight;

@end
