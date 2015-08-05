//
//  UIView+ACTQuickLook.h
//  LocationMapper
//
//  Created by David Solberg on 5/26/14.
//  Copyright (c) 2014 David Solberg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (ACTQuickLook)

/// Debugging method that allows any view to be seen in the debugger. In practice, this doesn't always work, but it's super useful when it does.
- (UIImage *)debugQuickLookObject;

@end
