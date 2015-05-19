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

+ (CGSize) sizeForNibName:(NSString *)nibName;
+ (UIView *)topLevelViewForNibName:(NSString *)nibName;


@end
