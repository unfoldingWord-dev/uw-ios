//
//  UFWFirstLaunchInfoVC.h
//  UnfoldingWord
//
//  Created by David Solberg on 6/5/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LaunchInfoDelegate <NSObject>
-(void)userTappedAppInfo:(id)sender;

@end

@interface UFWFirstLaunchInfoVC : UIViewController

@property (nonatomic, strong) id <LaunchInfoDelegate> delegate;

@end
