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

/// Call only from a static cells used to tell the UITableview's height.
- (CGFloat)calculatedHeight;

/// The estimated height to use to improve scrolling speed.
+ (CGFloat)estimatedHeight;

@end
