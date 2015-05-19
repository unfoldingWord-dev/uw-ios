//
//  UFWStatusInfoViewController.m
//  UnfoldingWord
//
//  Created by David Solberg on 5/15/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

#import "UFWStatusInfoViewController.h"
#import "UFWInfoView.h"
#import "NSLayoutConstraint+DWSExtensions.h"

@interface UFWStatusInfoViewController ()
@property (nonatomic, strong) UFWInfoView *infoView;
@end

@implementation UFWStatusInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.infoView = [UFWInfoView newView];
    self.infoView.isAlwaysHidDelete = YES;
    self.infoView.status = self.status;
    self.infoView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSArray *constraints = [NSLayoutConstraint constraintsForView:self.infoView insideView:self.view topMargin:0 leftMargin:0 rightMargin:0 minimumHeight:10];
    [self.view addSubview:self.infoView];
    [self.view addConstraints:constraints];
}

@end
