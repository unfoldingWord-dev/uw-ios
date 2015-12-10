//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

#import "_UWVersion.h"
#import "Constants.h"

@class UWLanguage;

typedef void (^VersionCompletion) (BOOL success, NSString *errorMessage);
extern NSString *const kNotificationDownloadCompleteForVersion;
extern NSString *const kKeyVersionId;

extern NSString *const kNotificationVersionContentDelete;

@interface UWVersion : _UWVersion {}

/// Method to update from JSON array
+ (void)updateVersions:(NSArray *)versions forLanguage:(UWLanguage *)language;

/// Downloads all attach TOC objects with a completion block
- (void)downloadUsingOptions:(DownloadOptions)options completion:(VersionCompletion)completion;

/// Checks if any attached TOC objects have a failed download
- (BOOL)isAnyTextFailedDownload;

- (DownloadStatus)statusText;
- (DownloadStatus)statusAudio;
- (DownloadStatus)statusVideo;

/// Check this bitmask to see if which items are currently downloading. DownloadOptionsEmpty means that the item is not downloading.
- (DownloadOptions)currentDownloadingOptions;

/// Deletes all downloaded content for attached TOC objects
//- (BOOL)deleteAllContent;
- (BOOL)deleteContentForDownloadOptions:(DownloadOptions)options;

- (NSArray *)sortedTOCs;

/// Returns a json representation of the version and its status information and TOC object array.
- (NSDictionary *)jsonRepresention;

/// A filename to use to display for the user. This filename is not guaranteed to be unique, but it generally will be.
- (NSString *)filename;

@end
