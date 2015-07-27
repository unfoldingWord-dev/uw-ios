//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

#import "_UWTOC.h"

@class UWVersion, OpenChapter, UWFile;

typedef void (^TOCDownloadCompletion) (BOOL success);

@interface UWTOC : _UWTOC {}

+ (void)updateTOCitems:(NSArray *)tocItems forVersion:(UWVersion *)version;

- (void)downloadWithCompletion:(TOCDownloadCompletion)completion;

- (BOOL)deleteAllContent;

- (BOOL)isDownloadedAndValid;

- (OpenChapter *)chapterForNumber:(NSInteger)number;

- (NSDictionary *)jsonRepresention;

- (BOOL)importWithUSFM:(NSString *)usfm signature:(NSString *)signature;

- (BOOL)importWithOpenBible:(NSString *)openBible signature:(NSString *)signature;

@end
