//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

#import "OpenFrame.h"
#import "UWCoreDataClasses.h"

static NSString *const kId = @"id";
static NSString *const kImageUrl = @"img";
static NSString *const kText = @"text";

@interface OpenFrame ()

@end

@implementation OpenFrame

+ (instancetype)frameForDictionary:(NSDictionary *)dictionary forChapter:(OpenChapter *)chapter;
{
    NSString *frameId = [dictionary objectOrNilForKey:kId];
    NSAssert2([frameId isKindOfClass:[NSString class]], @"%s: The chapter number must be  string in dictionary: %@", __PRETTY_FUNCTION__, dictionary);
    
    for (OpenFrame *existingFrame in chapter.frames) {
        if ([existingFrame.uid isEqualToString:frameId]) {
            [existingFrame updateWithDictionary:dictionary];
            return existingFrame;
        }
    }
    
    // If we got here, there is no existing chapter
    OpenFrame *frame = [OpenFrame insertInManagedObjectContext:[DWSCoreDataStack managedObjectContext]];
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
    [self stripHtmlFromText];
    [self stripMultipleReturnsFromText];
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

-(void)stripHtmlFromText {
    NSString *originalString = self.text;
    if (self.text.length ==0) {
        return;
    }
    
    NSRange r;
    NSString *s = [originalString copy];
    while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound) {
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    }
    self.text = s;
}

//

-(void)stripMultipleReturnsFromText {
    NSString *originalString = self.text;
    if (self.text.length == 0) {
        return;
    }
    
    NSRange r;
    NSString *s = [originalString copy];
    while ((r = [s rangeOfString:@"\n" options:NSRegularExpressionSearch]).location != NSNotFound) {
        s = [s stringByReplacingCharactersInRange:r withString:@" "];
    }
    while ((r = [s rangeOfString:@"  " options:NSRegularExpressionSearch]).location != NSNotFound) {
        s = [s stringByReplacingCharactersInRange:r withString:@" "];
    }
    self.text = s;
}

@end
