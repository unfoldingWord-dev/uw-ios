//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

#import "UFWFrame.h"
#import "DWSCoreDataStack.h"
#import "NSDictionary+DWSNull.h"
#import "UFWChapter.h"

static NSString *const kId = @"id";
static NSString *const kImageUrl = @"img";
static NSString *const kText = @"text";

@implementation UFWFrame

+ (UFWFrame *)frameForDictionary:(NSDictionary *)dictionary forChapter:(UFWChapter *)chapter;
{
    NSString *frameId = [dictionary objectOrNilForKey:kId];
    NSAssert2([frameId isKindOfClass:[NSString class]], @"%s: The chapter number must be  string in dictionary: %@", __PRETTY_FUNCTION__, dictionary);
    
    for (UFWFrame *existingFrame in chapter.frames) {
        if ([existingFrame.uid isEqualToString:frameId]) {
            [existingFrame updateWithDictionary:dictionary];
            return existingFrame;
        }
    }
    
    // If we got here, there is no existing chapter
    UFWFrame *frame = [UFWFrame insertInManagedObjectContext:[DWSCoreDataStack managedObjectContext]];
    frame.chapter = chapter;
    [frame updateWithDictionary:dictionary];
    return frame;
}

- (void)updateWithDictionary:(NSDictionary *)dictionary
{
    self.uid = [dictionary objectOrNilForKey:kId];
    self.imageUrl = [dictionary objectOrNilForKey:kImageUrl];
    self.text = [dictionary objectOrNilForKey:kText];

    [self fixUrlImageString];
}

/// Correct various errors in the image url from the JSON
- (void)fixUrlImageString
{
    NSString *fixedString = self.imageUrl;
    fixedString = [fixedString stringByReplacingOccurrencesOfString:@"{" withString:@""];
    fixedString = [fixedString stringByReplacingOccurrencesOfString:@"}" withString:@""];
    fixedString = [fixedString stringByReplacingOccurrencesOfString:@"[" withString:@""];
    fixedString = [fixedString stringByReplacingOccurrencesOfString:@"]" withString:@""];
    fixedString = [fixedString stringByReplacingOccurrencesOfString:@":http" withString:@"http"];
    fixedString = [fixedString stringByReplacingOccurrencesOfString:@"?direct&" withString:@""];
    self.imageUrl = fixedString;
}

@end
