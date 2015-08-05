//
//  NSBundle+DWSExtensions.h
//  LocationMapper
//
//  Created by David Solberg on 6/8/13.
//  Copyright (c) 2013 David Solberg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSBundle (DWSExtensions)

/// Extracts the top object in a nib, measures it and returns the size.
+ (CGSize) sizeForNibName:(NSString *)nibName;

/// Returns the top object for a nib. For example, for a nib with a tableview cell, it would return the cell.
+ (UIView *)topLevelViewForNibName:(NSString *)nibName;


@end
