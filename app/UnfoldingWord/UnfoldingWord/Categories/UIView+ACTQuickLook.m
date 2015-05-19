//
//  UIView+ACTQuickLook.m
//  LocationMapper
//
//  Created by David Solberg on 5/26/14.
//  Copyright (c) 2014 David Solberg. All rights reserved.
//

#import "UIView+ACTQuickLook.h"

@implementation UIView (ACTQuickLook)

- (UIImage *)debugQuickLookObject
{
    UIGraphicsBeginImageContextWithOptions(self.layer.bounds.size, NO, 0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
