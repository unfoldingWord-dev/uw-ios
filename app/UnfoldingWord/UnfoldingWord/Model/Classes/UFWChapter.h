//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

#import "_UFWChapter.h"

@interface UFWChapter : _UFWChapter {}

- (void)updateWithDictionary:(NSDictionary *)dictionary;

+ (UFWChapter *)chapterForDictionary:(NSDictionary *)dictionary forBible:(UFWBible *)bible;

- (NSArray *)sortedFrames;

@end
