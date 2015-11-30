//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

#import "OpenChapter.h"
#import "UWCoreDataClasses.h"
#import "Constants.h"
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

static NSString *const kTitle = @"title";
static NSString *const kReference = @"ref";
static NSString *const kNumber = @"number";
static NSString *const kFrames = @"frames";

@implementation OpenChapter

+ (NSArray *)createChaptersFromArray:(NSArray *)chapters forOpenContainer:(OpenContainer *)container
{
    NSMutableArray *array = [NSMutableArray new];
//    NSSet *oldChapters = container.chapters;
//    for (OpenChapter *chapter in oldChapters) {
//        [[DWSCoreDataStack managedObjectContext] deleteObject:chapter];
//    }
//    
    for (NSDictionary *dictionary in chapters) {
        [OpenChapter chapterForDictionary:dictionary forOpenContainer:container];
    }
    
    return array;
}

+ (instancetype)chapterForDictionary:(NSDictionary *)dictionary forOpenContainer:(OpenContainer *)container
{
    NSString *chapterNumberString = [dictionary objectOrNilForKey:kNumber];
    NSAssert2([chapterNumberString isKindOfClass:[NSString class]], @"%s: The chapter number must be  string in dictionary: %@", __PRETTY_FUNCTION__, dictionary);
    
    for (OpenChapter *existingChapter in container.chapters) {
        if ([existingChapter.number isEqualToString:chapterNumberString]) {
            [existingChapter updateWithDictionary:dictionary];
            return existingChapter;
        }
    }
    
    // If we got here, there is no existing chapter
    OpenChapter *chapter = [OpenChapter insertInManagedObjectContext:[DWSCoreDataStack managedObjectContext]];
    chapter.container = container;
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
        [OpenFrame frameForDictionary:dictionary forChapter:self];
    }
}


- (NSArray *)sortedFrames
{
    NSArray *sorted = [self.frames.allObjects sortedArrayUsingComparator:^NSComparisonResult(OpenFrame *frame1, OpenFrame *frame2) {
        NSNumber *num1 = [self numberFromString:frame1.uid];
        NSNumber *num2 = [self numberFromString:frame2.uid];
        return [num1 compare:num2];
    }];
    return sorted;
}

- (NSNumber *)numberFromString:(NSString *)string
{
    NSCharacterSet *nonNumberSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSRange r;
    NSString *s = [string copy];
    while ((r = [s rangeOfCharacterFromSet:nonNumberSet]).location != NSNotFound) {
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    }
    return @(s.integerValue);
}


- (NSAttributedString *)attributedText
{
    NSMutableAttributedString *string = [NSMutableAttributedString new];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineHeightMultiple = 1.05f;
    paragraphStyle.paragraphSpacing = 10.0f;
    paragraphStyle.firstLineHeadIndent = 10.0f;
    paragraphStyle.headIndent = 0.0f;
    
    UIFont *baseFont = [FONT_LIGHT fontWithSize:15];
    UIFont *superScriptFont = [baseFont fontWithSize:(baseFont.pointSize/1.2)];
    NSDictionary *superScript = @{NSBaselineOffsetAttributeName:@(baseFont.pointSize/1.5), NSFontAttributeName:superScriptFont, NSKernAttributeName:@(1)};
    NSDictionary *normal = @{NSBaselineOffsetAttributeName:@(5), NSFontAttributeName:baseFont};
    
    for (OpenFrame *frame in [self sortedFrames]) {
        NSAttributedString *superscript = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", frame.uid] attributes:superScript];
        NSAttributedString *text = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ", frame.text] attributes:normal];
        [string appendAttributedString:superscript];
        [string appendAttributedString:text];
    }
    
    [string addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:[string.string rangeOfString:string.string]];
    
    return string;
}

@end
