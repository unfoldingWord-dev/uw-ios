//
//  UINavigationController+UFWNavigationController.m
//  UnfoldingWord
//
//  Created by David Solberg on 5/13/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

#import "UINavigationController+UFWNavigationController.h"
#import "Constants.h"

@implementation UINavigationController (UFWNavigationController)

+ (UINavigationController *)navigationControllerWithUFWBaseViewController:(UIViewController *)vc
{
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:vc];
    navController.navigationBar.tintColor = [UIColor whiteColor];
    navController.navigationBar.barTintColor = BACKGROUND_GRAY;
    navController.navigationBar.translucent = YES;
    navController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil];
    return navController;
}

@end
