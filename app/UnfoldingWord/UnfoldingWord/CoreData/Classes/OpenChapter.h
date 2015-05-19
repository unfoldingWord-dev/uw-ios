//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

#import "_OpenChapter.h"
@class UWTOC;

@interface OpenChapter : _OpenChapter {}

+ (NSArray *)createChaptersFromArray:(NSArray *)chapters forOpenContainer:(OpenContainer *)container;

- (NSAttributedString *)attributedText;

- (NSArray *)sortedFrames;

@end
