//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

#import "_UFWBible.h"
@class UFWChapter;
@class UFWFrame;

@interface UFWBible : _UFWBible {}

@property (nonatomic, strong) UFWChapter *currentChapter;
@property (nonatomic, strong) UFWFrame *currentFrame;

+ (void)createOrUpdateBibleWithDictionary:(NSDictionary *)dictionary forLanguage:(UFWLanguage *)language;

- (NSArray *)sortedChapters;


@end
