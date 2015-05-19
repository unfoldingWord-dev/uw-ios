//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

#import "_UWVersion.h"
@class UWLanguage;

typedef void (^VersionCompletion) (BOOL success, NSString *errorMessage);
extern NSString *const kNotificationDownloadCompleteForVersion;
extern NSString *const kKeyVersionId;

extern NSString *const kNotificationVersionContentDelete;

@interface UWVersion : _UWVersion {}

/// Method to update from JSON array
+ (void)updateVersions:(NSArray *)versions forLanguage:(UWLanguage *)language;

/// Downloads all attach TOC objects with a completion block
- (void)downloadWithCompletion:(VersionCompletion)completion;

/// Checks if any attached TOC object is currently downloading
- (BOOL)isDownloading;

/// Checks if all attached TOC objects are validated
- (BOOL)isAllValid;

/// Checks if all attached TOC objects are downloaded
- (BOOL)isAllDownloaded;

/// Checks if any attached TOC objects have a failed download
- (BOOL)isAnyFailedDownload;

/// Deletes all downloaded content for attached TOC objects
- (BOOL)deleteAllContent;

- (NSArray *)sortedTOCs;

@end
