//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

#import "_UWTOC.h"
#import "UWDownloadOptions.h"

@class UWVersion, OpenChapter, UWFile;

typedef void (^TOCDownloadCompletion) (BOOL success);

@interface UWTOC : _UWTOC {}

@property (nonatomic, strong, readonly) NSString *chapterTitle;

+ (void)updateTOCitems:(NSArray *)tocItems forVersion:(UWVersion *)version;

- (void)downloadUsingOptions:(DownloadOptions)options completion:(TOCDownloadCompletion)completion;

- (BOOL)deleteAllContent;

- (BOOL)isDownloadedForOptions:(DownloadOptions)options;
- (BOOL)isDownloadedAndValidForOptions:(DownloadOptions)options;

// Check audio download status
- (BOOL)hasAudio;
- (BOOL)allAudioDownloaded;
- (BOOL)allAudioDownloadedAndValid;
- (BOOL)anyAudioDownloaded;

// Check video download status
- (BOOL)hasVideo;
- (BOOL)allVideoDownloaded;
- (BOOL)allVideoDownloadedAndValid;
- (BOOL)anyVideoDownloaded;

- (OpenChapter *)chapterForNumber:(NSInteger)number;

- (NSDictionary *)jsonRepresention;

- (BOOL)importWithUSFM:(NSString *)usfm signature:(NSString *)signature;

- (BOOL)importWithOpenBible:(NSString *)openBible signature:(NSString *)signature;

// Returns the audio url for a given chapter in a TOC object. Does NOT validate that the source is correctly signed.
- (NSURL *)urlAudioForChapter:(NSInteger)chapter;

@end
