//
//  UWExpandableLanguageCell.h
//  UnfoldingWord
//
//  Created by David Solberg on 5/7/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UFWVersionCell;
@class UWVersion;

@protocol CellExpandableDelegate <NSObject>
- (void)cellDidChangeExpandedState:(UFWVersionCell *)cell;
@end

@interface UFWVersionCell : UITableViewCell
@property (nonatomic, weak) id <CellExpandableDelegate> delegate;
@property (nonatomic, strong) UWVersion *version;
@property (nonatomic, assign) BOOL isExpanded;
@property (nonatomic, assign) BOOL isSelected;

+ (CGFloat)heightForVersion:(UWVersion *)version expanded:(BOOL)isExpanded forWidth:(CGFloat)width;

@end
