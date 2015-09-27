
//
//  UFWAppInformationVC.m
//  UnfoldingWord
//
//  Created by David Solberg on 6/5/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

#import "UFWAppInformationView.h"
#import "Constants.h"
#import "NSBundle+DWSExtensions.h"
#import "NSLayoutConstraint+DWSExtensions.h"

@interface UFWAppInformationView ()
@property (nonatomic, weak) IBOutlet UILabel *labelAppInfoTop;
@property (nonatomic, weak) IBOutlet UILabel *labelOverview;
@property (nonatomic, weak) IBOutlet UILabel *labelLevel1Text;
@property (nonatomic, weak) IBOutlet UILabel *labelLevel2Text;
@property (nonatomic, weak) IBOutlet UILabel *labelLevel3Text;
@property (nonatomic, weak) IBOutlet UILabel *labelVerifyTitle;
@property (nonatomic, weak) IBOutlet UILabel *labelVerified;
@property (nonatomic, weak) IBOutlet UILabel *labelExpired;
@property (nonatomic, weak) IBOutlet UILabel *labelFailed;
@property (nonatomic, weak) IBOutlet UILabel *labelAppVersion;

@property (nonatomic, weak) IBOutlet UIImageView *imageviewLevel1;
@property (nonatomic, weak) IBOutlet UIImageView *imageviewLevel2;
@property (nonatomic, weak) IBOutlet UIImageView *imageviewLevel3;
@property (nonatomic, weak) IBOutlet UIImageView *imageviewVerified;
@property (nonatomic, weak) IBOutlet UIImageView *imageviewExpired;
@property (nonatomic, weak) IBOutlet UIImageView *imageviewFailed;

@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *arrayOfLabels;
@end

@implementation UFWAppInformationView

+ (instancetype)newView
{
    UFWAppInformationView *view = (UFWAppInformationView *)[NSBundle topLevelViewForNibName:NSStringFromClass([self class])];
    NSAssert2([view isKindOfClass:[self class]], @"%s: The view was the wrong type of class: %@", __PRETTY_FUNCTION__, view);
    [view setAllContent];
    return (UFWAppInformationView *)view;
}

- (void)setAllContent
{
    self.backgroundColor = BACKGROUND_GREEN;
    for (UILabel *label in self.arrayOfLabels) {
        label.font = [FONT_LIGHT fontWithSize:label.font.pointSize];
        label.textColor = [UIColor whiteColor];
    }
    
    self.labelAppInfoTop.font = [FONT_MEDIUM fontWithSize:17];
    self.labelVerifyTitle.font = [FONT_MEDIUM fontWithSize:self.labelVerifyTitle.font.pointSize];
    
    self.labelAppInfoTop.text = NSLocalizedString(@"App Information", nil);
    self.labelOverview.text = NSLocalizedString(@"We use a three-level, Church-centric approach for identifying the fidelity of translated Biblical content:", nil);
    self.labelLevel1Text.text = LEVEL_1_DESC;
    self.labelLevel2Text.text = LEVEL_2_DESC;
    self.labelLevel3Text.text = LEVEL_3_DESC;
    self.labelVerifyTitle.text = NSLocalizedString(@"Version Verification Status", nil);
    self.labelVerified.text = NSLocalizedString(@"Verified", nil);
    self.labelExpired.text = NSLocalizedString(@"Expired", nil);
    self.labelFailed.text = NSLocalizedString(@"Failed", nil);
    
    self.labelAppVersion.text = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    self.imageviewLevel1.image = [UIImage imageNamed:LEVEL_1_REVERSE];
    self.imageviewLevel2.image = [UIImage imageNamed:LEVEL_2_REVERSE];
    self.imageviewLevel3.image = [UIImage imageNamed:LEVEL_3_REVERSE];
    self.imageviewVerified.image = [UIImage imageNamed:IMAGE_VERIFY_GOOD];
    self.imageviewExpired.image = [UIImage imageNamed:IMAGE_VERIFY_EXPIRE];
    self.imageviewFailed.image = [UIImage imageNamed:IMAGE_VERIFY_FAIL];
}

+ (CGSize)sizeForWidth:(CGFloat)width;
{
    static UFWAppInformationView *_infoView = nil;
    static UIView *_container = nil;
    CGRect containerRect = CGRectMake(0, 0, width, 10000);
    if (_infoView == nil) {
        _container = [[UIView alloc] initWithFrame:containerRect];
        _infoView = [UFWAppInformationView newView];
        _infoView.translatesAutoresizingMaskIntoConstraints = NO;
        NSArray *constraints = [NSLayoutConstraint constraintsForView:_infoView insideView:_container topMargin:0 leftMargin:0 rightMargin:0 minimumHeight:10];
        [_container addSubview:_infoView];
        [_container addConstraints:constraints];
    }
    
    _container.frame = containerRect;
    
    [_container setNeedsUpdateConstraints];
    [_container setNeedsLayout];
    [_container layoutIfNeeded];
    
    [_infoView setNeedsUpdateConstraints];
    [_infoView setNeedsLayout];
    [_infoView layoutIfNeeded];
    
    CGSize size = _infoView.frame.size;
    
    return size;
}

// Apple's layout system doesn't properly figure out multi-line labels, so we need to do manually fix this during subview layout.
- (void)layoutSubviews
{
    for (UILabel *label in @[self.labelLevel1Text, self.labelLevel2Text, self.labelLevel3Text, self.labelOverview]) {
        [self adjustMultiLineLabel:label];
    }
    [super layoutSubviews];
}

- (void)adjustMultiLineLabel:(UILabel *)label
{
    [label setNeedsUpdateConstraints];
    [label setNeedsLayout];
    [label layoutIfNeeded];
    label.preferredMaxLayoutWidth = label.frame.size.width;
    [label setNeedsUpdateConstraints];
    [label setNeedsLayout];
    [label layoutIfNeeded];
}

@end
