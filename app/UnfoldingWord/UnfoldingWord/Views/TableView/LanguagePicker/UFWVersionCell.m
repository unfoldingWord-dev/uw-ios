//
//  UWExpandableLanguageCell.m
//  UnfoldingWord
//
//  Created by David Solberg on 5/7/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

#import "UFWVersionCell.h"
#import "UWCoreDataClasses.h"
#import "UFWInfoView.h"
#import "Constants.h"
#import "UFWInfoView.h"
#import "NSBundle+DWSExtensions.h"

@interface UFWVersionCell ()
@property (nonatomic, weak) IBOutlet UIImageView *imageViewCheckLevel;
@property (nonatomic, weak) IBOutlet UIImageView *imageViewVerify;
@property (nonatomic, weak) IBOutlet UILabel *labelName;
@property (nonatomic, weak) IBOutlet UIButton *buttonDisclosure;
@property (nonatomic, weak) IBOutlet UIButton *buttonDownload;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, assign) BOOL isDownloading;
@property (nonatomic, strong) UFWInfoView *infoViewExpanded;
@end

@implementation UFWVersionCell

+ (instancetype)newView
{
    UIView *view = [NSBundle topLevelViewForNibName:NSStringFromClass([self class])];
    NSAssert2([view isKindOfClass:[self class]], @"%s: The view was the wrong type of class: %@", __PRETTY_FUNCTION__, view);
    return (UFWVersionCell *)view;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.buttonDisclosure addTarget:self action:@selector(userPressedExpandContractButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonDownload addTarget:self action:@selector(userPressedDownloadButton:) forControlEvents:UIControlEventTouchUpInside];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationDownloadComplete:) name:kNotificationDownloadCompleteForVersion object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setVersion:(UWVersion *)version
{
    _version = version;
    
    switch (version.status.checking_level.integerValue) {
        case 1:
            self.imageViewCheckLevel.image = [UIImage imageNamed:LEVEL_1_IMAGE];
            break;
        case 2:
            self.imageViewCheckLevel.image = [UIImage imageNamed:LEVEL_2_IMAGE];
            break;
        case 3:
            self.imageViewCheckLevel.image = [UIImage imageNamed:LEVEL_3_IMAGE];
            break;
        default:
            self.imageViewCheckLevel.image = nil;
            break;
    }
    
    self.labelName.text = self.version.name;
    
    if (self.isExpanded) {
        [self addExpandedView];
        self.contentView.backgroundColor = [UIColor colorWithRed:.91 green:.91 blue:.91 alpha:1];
    }
    else {
        [self removeExpandedView];
        self.contentView.backgroundColor = [UIColor whiteColor];
    }
    
    [self updateDownloadInfo];
}

- (void)setIsSelected:(BOOL)isSelected
{
    _isSelected = isSelected;
    self.labelName.textColor = (isSelected) ? SELECTION_BLUE_COLOR : [UIColor blackColor];
}

- (void)addExpandedView;
{
    if (self.infoViewExpanded == nil || self.infoViewExpanded.superview == nil) {
        UFWInfoView *infoView = [UFWInfoView newView];
        infoView.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSLayoutConstraint *leftEdge = [NSLayoutConstraint constraintWithItem:infoView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:10];
        NSLayoutConstraint *rightEdge = [NSLayoutConstraint constraintWithItem:infoView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1 constant:0];
        NSLayoutConstraint *topEdge = [NSLayoutConstraint constraintWithItem:infoView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.imageViewCheckLevel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:8];
        
        [self.contentView addSubview:infoView];
        [self.contentView addConstraints:@[leftEdge, rightEdge, topEdge]];
        self.infoViewExpanded = infoView;
    }
    
    [self.infoViewExpanded setStatus:self.version.status];
    self.infoViewExpanded.layer.opacity = 0.0;
    [UIView animateWithDuration:.25 delay:.2 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.infoViewExpanded.layer.opacity = 1.0;
    } completion:^(BOOL finished) {}];
}

- (void)removeExpandedView;
{
    [self.infoViewExpanded removeFromSuperview];
    self.infoViewExpanded = nil;
}

#pragma mark - Downloading

- (void) userPressedDownloadButton:(UIButton *)button
{
    [self showDownloading];
    [self.version downloadWithCompletion:^(BOOL success, NSString *errorMessage) {} ];
}

- (void)showDownloading
{
    [self.activityIndicator startAnimating];
    self.imageViewVerify.hidden = YES;
    self.buttonDownload.hidden = YES;
}

- (void)showDownloadComplete
{
    [self.activityIndicator stopAnimating];
    self.imageViewVerify.hidden = NO;
    if ([self.version isAllValid]) {
        self.imageViewVerify.image = [UIImage imageNamed:IMAGE_VERIFY_GOOD];
    }
    else {
        self.imageViewVerify.image = [UIImage imageNamed:IMAGE_VERIFY_FAIL];
    }
    self.buttonDownload.hidden = YES;
}

- (void)showDownloadFailed
{
    [self.activityIndicator stopAnimating];
    self.buttonDownload.hidden = NO;
    self.imageViewVerify.hidden = YES;
    [self.buttonDownload setBackgroundImage:[UIImage imageNamed:IMAGE_VERIFY_EXPIRE] forState:UIControlStateNormal];
}

- (void)showUndownloaded
{
    [self.activityIndicator stopAnimating];
    self.buttonDownload.hidden = NO;
    [self.buttonDownload setBackgroundImage:[UIImage imageNamed:@"download_arrow.png"] forState:UIControlStateNormal];
    self.imageViewVerify.hidden = YES;
}

- (void)notificationDownloadComplete:(NSNotification *)notification
{
    NSString *versionId = notification.userInfo[kKeyVersionId];
    if ([self.version.objectID.URIRepresentation.absoluteString isEqualToString:versionId]) {
        [self updateDownloadInfo];
    }
}

- (void)updateDownloadInfo
{
    if ([self.version isDownloading]) {
        [self showDownloading];
    }
    else if (self.version.isAnyFailedDownload) {
        [self showDownloadFailed];
    }
    else if (self.version.isAllDownloaded) {
        [self showDownloadComplete];
    }
    else {
        [self showUndownloaded];
    }
}

#pragma mark - Expanding

- (void)userPressedExpandContractButton:(UIButton *)button
{
    [self.delegate cellDidChangeExpandedState:self];
}

- (void)setIsExpanded:(BOOL)isExpanded
{
    _isExpanded = isExpanded;
    [self setVersion:_version];
}

#pragma mark - Fitting

+ (instancetype)sizingCell
{
    static UFWVersionCell *_sizingCell = nil;
    if (_sizingCell == nil) {
        _sizingCell = [self newView];
        _sizingCell.hidden = true;
    }
    return _sizingCell;
}

+ (CGFloat)heightForVersion:(UWVersion *)version expanded:(BOOL)isExpanded forWidth:(CGFloat)width;
{
    UFWVersionCell *sizingCell = [self sizingCell];
    static CGFloat const margin = 8.0f;
    CGFloat normalBottom = CGRectGetMaxY(sizingCell.imageViewCheckLevel.frame);
    if (isExpanded == NO) {
        return normalBottom + margin;
    }
    else {
        sizingCell.version = version;
        [sizingCell setIsExpanded:YES];
        sizingCell.bounds = CGRectMake(0, 0, width, 10000);
        sizingCell.contentView.bounds = CGRectMake(0, 0, width, 10000);
        UFWInfoView *infoView = sizingCell.infoViewExpanded;
        [infoView setNeedsUpdateConstraints];
        [infoView setNeedsLayout];
        [infoView layoutIfNeeded];
        return sizingCell.infoViewExpanded.frame.size.height + normalBottom + (2*margin);
    }
}

@end
