//
//  UFWInfoView.m
//  UnfoldingWord
//
//  Created by David Solberg on 5/7/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

#import "UFWInfoView.h"
#import "UWCoreDataClasses.h"
#import "Constants.h"
#import "NSBundle+DWSExtensions.h"
#import "NSLayoutConstraint+DWSExtensions.h"

static CGFloat const kButtonDeleteHeight = 30;
static CGFloat const kMargin = 8;
static CGFloat const kSpacer = 12;

@interface UFWInfoView ()
@property (nonatomic, weak) IBOutlet UILabel *labelVerifyTitle;
@property (nonatomic, weak) IBOutlet UILabel *labelVerifyText;
@property (nonatomic, weak) IBOutlet UILabel *labelCheckingEntityTitle;
@property (nonatomic, weak) IBOutlet UILabel *labelCheckingEntityText;
@property (nonatomic, weak) IBOutlet UILabel *labelCheckingLevelTitle;
@property (nonatomic, weak) IBOutlet UILabel *labelCheckingLevelText;
@property (nonatomic, weak) IBOutlet UILabel *labelVersionTitle;
@property (nonatomic, weak) IBOutlet UILabel *labelVersionText;
@property (nonatomic, weak) IBOutlet UILabel *labelPublishTitle;
@property (nonatomic, weak) IBOutlet UILabel *labelPublishText;

@property (nonatomic, weak) IBOutlet UIButton *buttonDelete;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *constraintHeightButton;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *constraintSpaceToButton;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *constraintVerifySpacer;

@property (nonatomic, weak) IBOutlet UIImageView *imageViewCheckLevel;

@end

@implementation UFWInfoView

+ (instancetype)newView
{
    UFWInfoView *view = (UFWInfoView *)[NSBundle topLevelViewForNibName:NSStringFromClass([self class])];
    NSAssert2([view isKindOfClass:[self class]], @"%s: The view was the wrong type of class: %@", __PRETTY_FUNCTION__, view);
    [view.buttonDelete setTitle:NSLocalizedString(@"Delete", nil) forState:UIControlStateNormal];
    return (UFWInfoView *)view;
}

- (void) setStatus:(UWStatus *)status
{
    _status = status;
    [self updateContent];
}

- (void)updateContent
{
    [self setUpLabels];
    
    // Verification Info
    DownloadStatus downloadTextStatus = [self.status.uwversion statusText];
    if (downloadTextStatus & DownloadStatusNone) {
        self.labelVerifyText.text = nil;
        self.labelVerifyTitle.text = nil;
        self.constraintVerifySpacer.constant = 0;
    }
    else {
        self.labelVerifyTitle.text = NSLocalizedString(@"Verification Information", nil);
        self.constraintVerifySpacer.constant = kSpacer;
        if (downloadTextStatus & DownloadStatusAllValid) {
            self.labelVerifyText.text = NSLocalizedString(@"This content is verified by: unfoldingWord", nil);
        }
        else {
            self.labelVerifyText.text = NSLocalizedString(@"Error verifying content.", nil);
        }
    }
    
    // Checking Entity
    self.labelCheckingEntityText.text = self.status.checking_entity;
    
    // Checking Level
    NSString *checkingText = @"Not found.";
    NSString *imageName = @"";
    switch (self.status.checking_level.integerValue) {
        case 1:
            checkingText = LEVEL_1_DESC;
            imageName = LEVEL_1_IMAGE;
            break;
        case 2:
            checkingText = LEVEL_2_DESC;
            imageName = LEVEL_2_IMAGE;
            break;
        case 3:
            checkingText = LEVEL_3_DESC;
            imageName = LEVEL_3_IMAGE;
            break;
        default:
            break;
    }
    self.labelCheckingLevelText.text = checkingText;
    self.imageViewCheckLevel.image = [UIImage imageNamed:imageName];

    // Version and Publish Date
    self.labelVersionText.text = self.status.version;
    self.labelPublishText.text = self.status.publish_date;
    
    if ( (downloadTextStatus & DownloadStatusSome) && self.isAlwaysHidDelete == NO) {
        self.constraintHeightButton.constant = kButtonDeleteHeight;
        self.constraintSpaceToButton.constant = kMargin;
        self.buttonDelete.hidden = NO;
    }
    else {
        self.constraintHeightButton.constant = 0;
        self.constraintSpaceToButton.constant = 0;
        self.buttonDelete.hidden = YES;
    }
}

+ (UIImage *)imageReverseForStatus:(UWStatus *)status
{
    NSString *imageName = @"";
    switch (status.checking_level.integerValue) {
        case 1:
            imageName = @"level1";
            break;
        case 2:
            imageName = @"level2";
            break;
        case 3:
            imageName = @"level3";
            break;
        default:
            break;
    }
    return [UIImage imageNamed:imageName];
}


- (IBAction)deleteDownloads
{
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Delete", nil) message:NSLocalizedString(@"Remove content from device?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Dismiss", nil) otherButtonTitles: NSLocalizedString(@"Delete", nil), nil] show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonName = [alertView buttonTitleAtIndex:buttonIndex];
    if ([buttonName isEqualToString:NSLocalizedString(@"Delete", nil)]) {
        if ([self.status.uwversion deleteAllContent] == NO) {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Could not delete all content.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss", nil) otherButtonTitles: nil] show];
        }
        else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationVersionContentDelete object:nil userInfo:@{kKeyVersionId:self.status.uwversion.objectID.URIRepresentation.absoluteString}];
        }
    }
}

- (void)setUpLabels
{
    self.labelVerifyTitle.text = NSLocalizedString(@"Verification Information", nil);
    self.labelCheckingEntityTitle.text = NSLocalizedString(@"Checking Entity", nil);
    self.labelCheckingLevelTitle.text = NSLocalizedString(@"Checking Level", nil);
    self.labelVersionTitle.text = NSLocalizedString(@"Version", nil);
    self.labelPublishTitle.text = NSLocalizedString(@"Publish Date", nil);
    
    UIFont *titleFont = [FONT_MEDIUM fontWithSize:16];
    self.labelVerifyTitle.font = titleFont;
    self.labelCheckingEntityTitle.font = titleFont;
    self.labelCheckingLevelTitle.font = titleFont;
    self.labelVersionTitle.font = titleFont;
    self.labelPublishTitle.font = titleFont;
    
    UIFont *textFont = [FONT_LIGHT fontWithSize:15];
    self.labelVerifyText.font = textFont;
    self.labelCheckingEntityText.font = textFont;
    self.labelCheckingLevelText.font = textFont;
    self.labelVersionText.font = textFont;
    self.labelPublishText.font = textFont;
}

// Apple's layout system doesn't properly figure out multi-line labels, so we need to do manually fix this during subview layout.
- (void)layoutSubviews
{
    [self adjustMultiLineLabel:self.labelVerifyText];
    [self adjustMultiLineLabel:self.labelCheckingEntityTitle];
    [self adjustMultiLineLabel:self.labelCheckingLevelText];
    
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

+ (CGSize)sizeForStatus:(UWStatus *)status forWidth:(CGFloat)width withDeleteButton:(BOOL)showDeleteWhenAvailable
{
    static UFWInfoView *_infoView = nil;
    static UIView *_container = nil;
    CGRect containerRect = CGRectMake(0, 0, width, 10000);
    if (_infoView == nil) {
        _container = [[UIView alloc] initWithFrame:containerRect];
        _infoView = [UFWInfoView newView];
        _infoView.translatesAutoresizingMaskIntoConstraints = NO;
        NSArray *constraints = [NSLayoutConstraint constraintsForView:_infoView insideView:_container topMargin:0 leftMargin:0 rightMargin:0 minimumHeight:10];
        [_container addSubview:_infoView];
        [_container addConstraints:constraints];
    }
    
    _container.frame = containerRect;
    _infoView.isAlwaysHidDelete = ! showDeleteWhenAvailable;
    _infoView.status = status;
    
    [_container setNeedsUpdateConstraints];
    [_container setNeedsLayout];
    [_container layoutIfNeeded];
    
    [_infoView setNeedsUpdateConstraints];
    [_infoView setNeedsLayout];
    [_infoView layoutIfNeeded];
    
    CGSize size = _infoView.frame.size;
    size.height += 10.f; // extra space after last item.
    
    [_container removeFromSuperview];
    
    return size;
}

@end
