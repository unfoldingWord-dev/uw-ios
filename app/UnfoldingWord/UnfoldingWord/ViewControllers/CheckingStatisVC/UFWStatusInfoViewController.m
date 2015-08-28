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
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UFWInfoView *infoView;
@end

@implementation UFWStatusInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.scrollView = [UIScrollView new];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    NSArray *constraints = [NSLayoutConstraint constraintsForView:self.scrollView insideView:self.view topMargin:0 bottomMargin:0 leftMargin:0 rightMargin:0];
    [self.view addSubview:self.scrollView];
    [self.view addConstraints:constraints];
    
    self.infoView = [UFWInfoView newView];
    self.infoView.isAlwaysHidDelete = YES;
    self.infoView.status = self.status;
    self.infoView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:self.infoView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:self.infoView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:self.infoView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:self.infoView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:self.infoView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
    
    [self.scrollView addSubview:self.infoView];
    [self.view addConstraints:@[top,bottom,left,right,width]];
}

@end
