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
#import "UnfoldingWord-Swift.h"
#import "NSLayoutConstraint+DWSExtensions.h"

@interface UFWVersionCell ()

@property (nonatomic, weak) IBOutlet UILabel *labelName;
@property (nonatomic, strong) NSArray *arrayMediaTypeViews;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationDownloadComplete:) name:kNotificationDownloadCompleteForVersion object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UIImage *)imageForCheckingLevel:(NSInteger)level {
    switch (level) {
        case 1:
            return [UIImage imageNamed:LEVEL_1_IMAGE];
            break;
        case 2:
            return [UIImage imageNamed:LEVEL_2_IMAGE];
            break;
        case 3:
            return [UIImage imageNamed:LEVEL_3_IMAGE];
            break;
        default:
            return nil;
    }
}

- (void)removeAllExistingMediaTypeViews {
    for (UIView *view in self.arrayMediaTypeViews) {
        [view removeFromSuperview];
    }
    self.arrayMediaTypeViews = nil;
}

- (void)setVersion:(UWVersion *)version
{
    _version = version;
    
    self.labelName.text = self.version.name;
    
    [self removeAllExistingMediaTypeViews];
    
    NSMutableArray *views = [NSMutableArray new];
    [views addObject:[self createMediaViewWithType:MediaTypeText]];
    
    DownloadStatus audioStatus = [self.version statusAudio];
    DownloadStatus videoStatus = [self.version statusVideo];

    if ( audioStatus != DownloadStatusNoContent) {
        [views addObject:[self createMediaViewWithType:MediaTypeAudio]];
    }
    if ( videoStatus != DownloadStatusNoContent ) {
        [views addObject:[self createMediaViewWithType:MediaTypeVideo]];
    }
    self.arrayMediaTypeViews = views;
    [self updateMediaViews];
    
    // Stack the subviews
    UIView *topView = self.labelName;
    for (MediaTypeView *mediaView in views) {
        NSArray *constraints = [NSLayoutConstraint constraintsToPutView:mediaView belowView:topView padding:8.0 withContainerView:self.contentView leftMargin:25 rightMargin:10];
        [self.contentView addSubview:mediaView];
        [self.contentView addConstraints:constraints];
        topView = mediaView;
    }
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:topView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:10];
    [self.contentView addConstraint:bottomConstraint];
}

- (void)updateMediaViews {
    for (MediaTypeView *mediaView in self.arrayMediaTypeViews) {
        [self updateMediaView:mediaView];
    }
}

#pragma mark - Downloading

- (void)downloadForMediaView:(MediaTypeView *)mediaView
{
    DownloadOptions currentOptions = [self.version currentDownloadingOptions];
    if ([self.version currentDownloadingOptions] != DownloadOptionsEmpty) {
        NSString * message = nil;
        if (currentOptions & DownloadOptionsAudio) {
            message = @"Wait for audio to finish downloading.";
        } else if (currentOptions & DownloadOptionsVideo) {
            message = @"Wait for video to finish downloading.";
        } else if (currentOptions & DownloadOptionsText) {
            message = @"Wait for text to finish downloading.";
        } else {
            NSAssert2(NO, @"%s: Nothing downloading for version: %@", __PRETTY_FUNCTION__, self.version);
            message = @"Error. Couldn't find anything downloading?!?";
        }
        
        [[[UIAlertView alloc] initWithTitle:@"Already Downloading" message:message delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil]show];
        return;
    }
    
    __block DownloadOptions options = [self downloadOptionsForMediaView:mediaView];
    if ([mediaView getType] == MediaTypeAudio) {
        
        __weak typeof(self) weak = self;
        
        AudioPickerView *picker = [AudioPickerView create:^(BOOL isLowQuality) {
            if (isLowQuality) {
                options = options | DownloadOptionsLowQuality;
            } else {
                options = options | DownloadOptionsHighQuality;
            }
            [weak downloadWithOptions:options];
        }];
         [self showDialog:picker];
    }
    else {
        [self downloadWithOptions:options];
    }
}

- (void)downloadWithOptions:(DownloadOptions)options {
    [self.version downloadUsingOptions:options completion:^(BOOL success, NSString *errorMessage) {}];
    [self updateMediaViews];
}

// Specify which items should start downloading when a user taps download for a given media view.
- (DownloadOptions)downloadOptionsForMediaView:(MediaTypeView *)mediaView {
    DownloadOptions options = DownloadOptionsEmpty;
    if ( ([self.version statusText] & DownloadStatusAll) == 0) {
        options = options | DownloadOptionsText;
    }
    switch ([mediaView getType]) {
        case MediaTypeNone:
            break;
        case MediaTypeText:
            options = options | DownloadOptionsText;
            break;
        case MediaTypeAudio:
            options = options | DownloadOptionsAudio;
            break;
        case MediaTypeVideo:
            options = options | DownloadOptionsVideo;
            break;
    }
    return options;
}

- (void)notificationDownloadComplete:(NSNotification *)notification
{
    NSString *versionId = notification.userInfo[kKeyVersionId];
    if ([self.version.objectID.URIRepresentation.absoluteString isEqualToString:versionId]) {
        [self updateMediaViews];
    }
}

- (BOOL)isDownloadingForType:(MediaType)type withActiveOptions:(DownloadOptions)options
{
    if (options == DownloadOptionsEmpty) {
        return NO;
    }
    else if (type == MediaTypeAudio) {
        return options & DownloadOptionsAudio;
    }
    else if (type == MediaTypeText) {
        return options & DownloadOptionsText;
    }
    else if (type == MediaTypeVideo) {
        return options & DownloadOptionsVideo;
    }
    return NO;
}

- (void)updateMediaView:(MediaTypeView *)mediaView {
    
    DownloadStatus status = [self statusForMediaView:mediaView];
    BOOL isDownloading = [self isDownloadingForType:[mediaView getType] withActiveOptions:[self.version currentDownloadingOptions]];
    
    if (isDownloading) {
        [mediaView hideRightEdgeViewsExcept:mediaView.activityIndicator];
        
        switch (mediaView.getType) {
            case MediaTypeNone:
                NSAssert1(NO, @"%s: Don't call this with no type!", __PRETTY_FUNCTION__);
                break;
            case MediaTypeText:
                mediaView.labelDescription.text = @"Downloading Text...";
                break;
            case MediaTypeAudio:
                mediaView.labelDescription.text = @"Downloading Audio...";
                break;
            case MediaTypeVideo:
                mediaView.labelDescription.text = @"Downloading Video...";
                break;
        }
        return;
    }
    
    // Handle right side button
    NSAssert2(status != DownloadStatusNoContent, @"%s: Do not show if there is no content: %@", __PRETTY_FUNCTION__, mediaView);
    if (status & DownloadStatusAllValid) {
        [mediaView.buttonCheckingLevel setBackgroundImage:[self imageForCheckingLevel:self.version.status.checking_level.integerValue] forState:UIControlStateNormal];
    } else if (status & DownloadStatusAll) {
        [mediaView.buttonCheckingLevel setBackgroundImage:[UIImage imageNamed:IMAGE_VERIFY_FAIL] forState:UIControlStateNormal];
    }
    
    if (status & DownloadStatusAll) {
        [mediaView hideRightEdgeViewsExcept:mediaView.buttonDelete];
    } else {
        [mediaView hideRightEdgeViewsExcept:mediaView.buttonDownload];
    }

    if (status & DownloadStatusAll ) {
        switch (mediaView.getType) {
            case MediaTypeNone:
                NSAssert1(NO, @"%s: Don't call this with no type!", __PRETTY_FUNCTION__);
                mediaView.labelDescription.text = @"---";
                break;
            case MediaTypeText:
                mediaView.labelDescription.text = @"Read";
                break;
            case MediaTypeAudio:
                mediaView.labelDescription.text = @"Play Audio";
                break;
            case MediaTypeVideo:
                mediaView.labelDescription.text = @"Play Video";
                break;
        }
    } else if (status & DownloadStatusNone || status & DownloadStatusSome) {
        switch (mediaView.getType) {
            case MediaTypeNone:
                NSAssert1(NO, @"%s: Don't call this with no type!", __PRETTY_FUNCTION__);
                mediaView.labelDescription.text = @"---";
                break;
            case MediaTypeText:
                mediaView.labelDescription.text = @"Download Text";
                break;
            case MediaTypeAudio:
                mediaView.labelDescription.text = @"Download Audio";
                break;
            case MediaTypeVideo:
                mediaView.labelDescription.text = @"Download Video";
                break;
        }
    } else {
        NSAssert2(NO, @"%s: Unexpected status %ld", __PRETTY_FUNCTION__, status);
    }
}

- (void)userPressedCheckingInformationForMediaView:(MediaTypeView *) mediaView
{
    VerseVerifyInfoView *infoView = [VerseVerifyInfoView verifyViewForVersion:self.version];
    [self showDialog:infoView];
}

- (void)userPressedBackgroundButtonForMediaView:(MediaTypeView *) mediaView
{
    // Don't do anything if we're downloading.
    if ([self.version currentDownloadingOptions] != DownloadOptionsEmpty) {
        return;
    }
    
    DownloadStatus status = [self statusForMediaView:mediaView];
    if (status & DownloadStatusSome) {
        [self.delegate userDidRequestShow:[mediaView getType] forVersion:self.version];
    } else {
        [self userPressedDownloadButtonForMediaView:mediaView];
    }
}

- (void)userPressedDownloadButtonForMediaView:(MediaTypeView *)mediaView {
    
        [self downloadForMediaView:mediaView];
}

- (void)userPressedDeleteButtonForMediaView:(MediaTypeView *)mediaView
{
    NSString *message = nil;
    MediaType type = [mediaView getType];
    switch (type) {
        case MediaTypeText:
        {
            BOOL hasAudio = ([self.version statusAudio] & DownloadStatusSome) == DownloadStatusSome;
            BOOL hasVideo = ([self.version statusVideo] & DownloadStatusSome) == DownloadStatusSome;
            if (hasAudio && hasVideo) {
                message = @"Delete all text? This will also delete all audio and video for this item.";
            } else if (hasAudio) {
                message = @"Delete all text? This will also delete all audio for this item.";
            }else if (hasVideo) {
                message = @"Delete all text? This will also delete all video for this item.";
            } else {  // just text
                message = @"Delete all text?";
            }
        }
            break;
        case MediaTypeAudio:
            message = @"Delete all audio?";
            break;
        case MediaTypeVideo:
            message = @"Delete all video?";
            break;
        case MediaTypeNone:
            NSAssert2(NO, @"%s: Nothing to delete for media view: %@", __PRETTY_FUNCTION__, mediaView);
            message = @"Error: Nothing to delete";
            break;
    }
    
    __weak typeof(self) weakself = self;
    __weak typeof(mediaView) weakMedia = mediaView;
    [UIAlertView showWithTitle:@"Delete" message:message cancelButtonTitle:@"Keep" otherButtonTitles:@[@"Delete"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex != 0) {
            [weakself deleteContentForMediaView:weakMedia];
        }
    }];
}

- (void)deleteContentForMediaView:(MediaTypeView *)mediaView
{
    MediaType mediaTypeToDelete = [mediaView getType];
    if (mediaTypeToDelete == MediaTypeText) {
        [self.version deleteContentForDownloadOptions:DownloadOptionsText | DownloadOptionsVideo | DownloadOptionsAudio];
    } else if (mediaTypeToDelete == MediaTypeAudio) {
        [self.version deleteContentForDownloadOptions:DownloadOptionsAudio];
    } else if (mediaTypeToDelete == MediaTypeVideo) {
        [self.version deleteContentForDownloadOptions:DownloadOptionsVideo];
    }
    
    [self updateMediaViews];
}

- (MediaTypeView *)createMediaViewWithType:(MediaType)type
{
    NSString *classname = NSStringFromClass([MediaTypeView class]);
    classname = [classname stringAfterLastPeriod];
    MediaTypeView *mediaView = (MediaTypeView *)[NSBundle topLevelViewForNibName:classname];
    mediaView.translatesAutoresizingMaskIntoConstraints = NO;
    __weak typeof(self) weak = self;
    __weak typeof(mediaView) weakMediaView = mediaView;
    
    [mediaView setDownloadButtonBlock:^{
        [weak userPressedDownloadButtonForMediaView:weakMediaView];
    }];
    [mediaView setCheckingLevelButtonBlock:^{
        [weak userPressedCheckingInformationForMediaView:weakMediaView];
    }];
    [mediaView setBackgroundButtonBlock:^{
        [weak userPressedBackgroundButtonForMediaView:weakMediaView];
    }];
    [mediaView setDeleteButtonBlock:^{
        [weak userPressedDeleteButtonForMediaView:weakMediaView];
    }];
    
    [mediaView.buttonCheckingLevel setBackgroundImage:[self imageForCheckingLevel:self.version.status.checking_level.integerValue] forState:UIControlStateNormal];
    [mediaView setType:type];
    
    return mediaView;
}

- (DownloadStatus)statusForMediaView:(MediaTypeView *)mediaView {
    switch (mediaView.getType) {
        case MediaTypeNone:
            return DownloadStatusNone;
            break;
        case MediaTypeText:
            return [self.version statusText];
            break;
        case MediaTypeAudio:
            return [self.version statusAudio];
            break;
        case MediaTypeVideo:
            return [self.version statusVideo];
            break;
    }
}

@end
