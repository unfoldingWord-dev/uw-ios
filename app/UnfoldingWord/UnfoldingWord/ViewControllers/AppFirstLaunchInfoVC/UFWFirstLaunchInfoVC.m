//
//  UFWFirstLaunchInfoVC.m
//  UnfoldingWord
//
//  Created by David Solberg on 6/5/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

#import "UFWFirstLaunchInfoVC.h"
#import "UFWAppInformationView.h"
#import "NSLayoutConstraint+DWSExtensions.h"
#import "Constants.h"

@interface UFWFirstLaunchInfoVC ()

@end

@implementation UFWFirstLaunchInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = BACKGROUND_GRAY;
    [self addInfoView];
    [self addGestureRecognizer];
}

- (void)addInfoView
{
    UFWAppInformationView *infoView = [UFWAppInformationView newView];
    infoView.translatesAutoresizingMaskIntoConstraints = NO;
    NSArray *constraints = [NSLayoutConstraint constraintsForView:infoView insideView:self.view topMargin:0 bottomMargin:0 leftMargin:0 rightMargin:0];
    [self.view addSubview:infoView];
    [self.view addConstraints:constraints];
}

- (void)addGestureRecognizer
{
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTapped:)];
    [self.view addGestureRecognizer:tapper];
}

- (void)userTapped:(id)sender
{
    [self.delegate userTappedAppInfo:self];
}

@end
