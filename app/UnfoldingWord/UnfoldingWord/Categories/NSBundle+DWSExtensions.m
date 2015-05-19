//
//  NSBundle+DWSExtensions.m
//  LocationMapper
//
//  Created by David Solberg on 6/8/13.
//  Copyright (c) 2013 David Solberg. All rights reserved.
//

#import "NSBundle+DWSExtensions.h"

@implementation NSBundle (DWSExtensions)

+ (CGSize) sizeForNibName:(NSString *)nibName
{
    NSArray *nibArray =[[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];
    if ([nibArray count]) {
        UIView *topView = nibArray[0];
        return topView.bounds.size;
    }
    else {
        NSAssert1([nibArray count], @"Could not load nib %@.", nibName);
        return CGSizeZero;
    }
}

+ (UIView *)topLevelViewForNibName:(NSString *)nibName
{
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];
    NSAssert2([views count], @"The nib array %@ for name %@ did not contain any views.", views, nibName);
    UIView *view = views[0];
    NSAssert2([view isKindOfClass:[UIView class]], @"The object %@ for nib name %@ is not a view.", view, nibName);
    return view;
}

@end
