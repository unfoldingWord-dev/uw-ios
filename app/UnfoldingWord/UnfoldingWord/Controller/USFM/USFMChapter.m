//
//  USFMChapter.m
//  UnfoldingWord
//
//  Created by David Solberg on 4/28/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

#import "USFMChapter.h"
#import "USFMElement.h"
#import "Constants.h"

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

static NSString *const kVerseNumber = @"USFWVerseNumber";

@interface USFMChapter ()
@property (nonatomic, strong) NSArray *elements;
@end

@implementation USFMChapter

- (NSString *)chapterNumber
{
    USFMElement *element = self.elements[0];
    if (element.isChapter) {
        return element.stringNumber;
    }
    else {
        NSAssert2(NO, @"%s: The first element was not the chapter. Element code: %@", __PRETTY_FUNCTION__, element.code);
        return nil;
    }
}

- (NSAttributedString *)attributedString
{
    // Create the formatting dictionaries we need
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineHeightMultiple = 1.0f;
    paragraphStyle.paragraphSpacing = 10.0f;
    paragraphStyle.firstLineHeadIndent = 15.0f;
    paragraphStyle.headIndent = 0.0f;

    UIFont *baseFont = FONT_LIGHT;
    UIFont *superScriptFont = [baseFont fontWithSize:(baseFont.pointSize/1.35)];
    NSDictionary *superScript = @{NSBaselineOffsetAttributeName:@(-1),NSKernAttributeName:@(1), NSFontAttributeName:superScriptFont, (NSString *)kCTSuperscriptAttributeName : @1};
    NSDictionary *normal = @{NSBaselineOffsetAttributeName:@(0), NSFontAttributeName:baseFont};
    
    
    NSMutableAttributedString *string = [NSMutableAttributedString new];
    
    for (USFMElement *element in self.elements) {
        
        if (element.isVerse) {
            
            if (element.stringNumber.length > 0) {
                NSAttributedString *superscript = [[NSAttributedString alloc] initWithString:element.stringNumber attributes:superScript];
                [string appendAttributedString:superscript];
            }
            
            if (element.text.length > 0) {
                NSMutableDictionary *normalVerse = [NSMutableDictionary dictionaryWithDictionary:normal];
                if (element.stringNumber.length > 0) {
                    normalVerse[kVerseNumber] = element.stringNumber;
                }
                NSAttributedString *text = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ", element.text] attributes:normal];
                [string appendAttributedString:text];
            }

        }
        else if (element.isParagraph && string.string.length > 0) { // Don't add returns to an empty string!
            NSAttributedString *para = [[NSAttributedString alloc] initWithString:@"\n" attributes:normal];
            [string appendAttributedString:para];
        }
    }
    
    NSRange textRange = [string.string rangeOfString:string.string];
    [string addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:textRange];
    
    return string;
}


#pragma mark - Create Chapters

+ (NSArray *)createChaptersFromElements:(NSArray *)elements
{
    NSMutableArray *chapters = [NSMutableArray new];
    NSMutableArray *chapterElements = nil;
    for (USFMElement *anElement in elements) {
        if (anElement.isChapter) {
            if (chapterElements.count > 0) { // Close out the previous chapter
                [chapters addObject:[self chapterWithElements:chapterElements]];
            }
            chapterElements = [NSMutableArray new];
        }
        // If we haven't reached the first chapter, these elements just go to nil.
        [chapterElements addObject:anElement];
    }
    
    // Take care of the last chapter
    if (chapterElements.count > 0) {
        [chapters addObject:[self chapterWithElements:chapterElements]];
    }
    
    return chapters;
}

#pragma mark - Internal

+ (USFMChapter *)chapterWithElements:(NSArray *)elements
{
    USFMChapter *chapter = [USFMChapter new];
    chapter.elements = elements;
    return chapter;
}

@end
