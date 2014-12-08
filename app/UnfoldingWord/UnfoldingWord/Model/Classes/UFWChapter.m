//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

#import "UFWChapter.h"
#import "UFWBible.h"
#import "DWSCoreDataStack.h"
#import "NSDictionary+DWSNull.h"
#import "UFWFrame.h"
static NSString *const kTitle = @"title";
static NSString *const kReference = @"ref";
static NSString *const kNumber = @"number";
static NSString *const kFrames = @"frames";


@implementation UFWChapter

+ (UFWChapter *)chapterForDictionary:(NSDictionary *)dictionary forBible:(UFWBible *)bible
{
    NSString *chapterNumberString = [dictionary objectOrNilForKey:kNumber];
    NSAssert2([chapterNumberString isKindOfClass:[NSString class]], @"%s: The chapter number must be  string in dictionary: %@", __PRETTY_FUNCTION__, dictionary);
    
    for (UFWChapter *existingChapter in bible.chapters) {
        if ([existingChapter.number isEqualToString:chapterNumberString]) {
            [existingChapter updateWithDictionary:dictionary];
            return existingChapter;
        }
    }
    
    // If we got here, there is no existing chapter
    UFWChapter *chapter = [UFWChapter insertInManagedObjectContext:[DWSCoreDataStack managedObjectContext]];
    chapter.bible = bible;
    [chapter updateWithDictionary:dictionary];
    return chapter;
}

- (void)updateWithDictionary:(NSDictionary *)dictionary;
{
    self.reference = [dictionary objectOrNilForKey:kReference];
    self.title = [dictionary objectOrNilForKey:kTitle];
    self.number = [dictionary objectOrNilForKey:kNumber];
    
    NSArray *framesArray = [dictionary objectOrNilForKey:kFrames];
    NSAssert2([framesArray isKindOfClass:[NSArray class]], @"%s: The dictionary did not contain a frames array: %@", __PRETTY_FUNCTION__, framesArray);
    
    for (NSDictionary *dictionary in framesArray) {
        NSAssert2([dictionary isKindOfClass:[NSDictionary class]], @"%s: The dictionary was not of the right class: %@", __PRETTY_FUNCTION__, dictionary);
        [UFWFrame frameForDictionary:dictionary forChapter:self];
    }
}

- (NSArray *)sortedFrames
{
    NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"uid" ascending:YES]];
    NSArray *sortedArray = [self.frames sortedArrayUsingDescriptors:sortDescriptors];
    return sortedArray;
}

@end
