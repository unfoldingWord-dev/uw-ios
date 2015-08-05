//
//  FrameCellDelegate.h
//  UnfoldingWord
//
//  Created by David Solberg on 8/2/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FrameCell;

@protocol FrameCellDelegate <NSObject>

- (void)showPopOverStatusInfo:(FrameCell *)cell view:(UIView *)view isSide:(BOOL)isSide;

- (void)showVersionSelector:(FrameCell *)cell view:(UIView *)view isSide:(BOOL)isSide;

- (void)showSharing:(FrameCell *)cell view:(UIView *)view isSide:(BOOL)isSide;

@end
