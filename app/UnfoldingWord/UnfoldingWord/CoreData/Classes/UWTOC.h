//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

#import "_UWTOC.h"
@class UWVersion, OpenChapter;

typedef void (^TOCDownloadCompletion) (BOOL success);

@interface UWTOC : _UWTOC {}

+ (void)updateTOCitems:(NSArray *)tocItems forVersion:(UWVersion *)version;

- (void)downloadWithCompletion:(TOCDownloadCompletion)completion;

- (BOOL)deleteAllContent;

- (OpenChapter *)chapterForNumber:(NSInteger)number;

@end
