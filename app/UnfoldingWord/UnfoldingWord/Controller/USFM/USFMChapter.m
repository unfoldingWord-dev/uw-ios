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
    UIFont *baseFont = [FONT_LIGHT fontWithSize:19];
    UIFont *superScriptFont = [baseFont fontWithSize:(baseFont.pointSize/1.35)];
    NSDictionary *superScript = @{NSBaselineOffsetAttributeName:@(-1),NSKernAttributeName:@(1), NSFontAttributeName:superScriptFont, (NSString *)kCTSuperscriptAttributeName : @1};
    NSDictionary *normal = @{NSBaselineOffsetAttributeName:@(0), NSFontAttributeName:baseFont};
    
    NSMutableAttributedString *string = [NSMutableAttributedString new];
    USFMElement *previousElement = nil;
    for (USFMElement *element in self.elements) {
        
        NSString *lastStringCharacter = (string.length > 0) ? [string.string substringWithRange:NSMakeRange(string.string.length-1, 1)] : nil;
        BOOL isLastCharacterReturn = ([lastStringCharacter rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location != NSNotFound);
        
        if (element.isVerse) {
            
            if (element.text.length > 0) {
                BOOL isShowQuote = (previousElement.isQuote && previousElement.text.length == 0);
                NSParagraphStyle *paraStyle = nil;
                if (isShowQuote) {
                    paraStyle = [self paragraphQuoteStyleWithIndentLevel:previousElement.numberMarker.floatValue];
                }
                else {
                    paraStyle = [self paragraphRegularStyle];
                }
                
                if (isShowQuote && isLastCharacterReturn == NO) {
                    [string appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n" attributes:normal]];
                }
                
                if (element.stringNumber.length > 0) {
                    NSMutableAttributedString *superscriptString = [[NSMutableAttributedString alloc] initWithString:element.stringNumber attributes:superScript];
                    [superscriptString addAttribute:NSParagraphStyleAttributeName value:paraStyle range:NSMakeRange(0, superscriptString.length)];
                    [string appendAttributedString:superscriptString];
                }
                
                NSMutableAttributedString *text = nil;
                if (isShowQuote) {
                    text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n", element.text] attributes:normal];
                }
                else {
                    text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ", element.text] attributes:normal];
                }
                [text addAttribute:NSParagraphStyleAttributeName value:paraStyle range:NSMakeRange(0, text.length)];
                [string appendAttributedString:text];
                
            }

        }
        else if (element.isQuote && element.text.length > 0) {
            NSMutableAttributedString *text = nil;
            if (isLastCharacterReturn == NO) {
                text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@\n", element.text] attributes:normal];
            }
            else {
                text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n", element.text] attributes:normal];
            }
            [text addAttribute:NSParagraphStyleAttributeName value:[self paragraphQuoteStyleWithIndentLevel:element.numberMarker.floatValue] range:NSMakeRange(0, text.length)];
            [string appendAttributedString:text];
            
        }
        else if ( (element.isParagraph || element.isLineBreak) && string.string.length > 0) { // Don't add returns to an empty string!
            NSAttributedString *para = [[NSAttributedString alloc] initWithString:@"\n" attributes:normal];
            [string appendAttributedString:para];
        }
        previousElement = element;
    }
    
    return string;
}

- (NSParagraphStyle *)paragraphQuoteStyleWithIndentLevel:(CGFloat)level
{
    CGFloat multiplier = 15.0f;
    CGFloat indent = (level + 2.0f) * multiplier;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineHeightMultiple = 1.35f;
    paragraphStyle.paragraphSpacing = 0.0f;
    paragraphStyle.firstLineHeadIndent = indent - multiplier;
    paragraphStyle.headIndent = indent;
    return paragraphStyle;
}

- (NSParagraphStyle *)paragraphRegularStyle
{
    // Create the formatting dictionaries we need
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineHeightMultiple = 1.35f;
    paragraphStyle.paragraphSpacing = 10.0f;
    paragraphStyle.firstLineHeadIndent = 15.0f;
    paragraphStyle.headIndent = 0.0f;
    return paragraphStyle;
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
