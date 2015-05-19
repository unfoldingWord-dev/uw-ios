//
//  UFWInfoView.h
//  UnfoldingWord
//
//  Created by David Solberg on 5/7/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UWStatus;

@interface UFWInfoView : UIView

+ (instancetype)newView;

@property (nonatomic, assign) BOOL isAlwaysHidDelete;
@property (nonatomic, strong) UWStatus *status;

+ (CGSize)sizeForStatus:(UWStatus *)status forWidth:(CGFloat)width withDeleteButton:(BOOL)showDeleteWhenAvailable;
+ (UIImage *)imageReverseForStatus:(UWStatus *)status;

@end
