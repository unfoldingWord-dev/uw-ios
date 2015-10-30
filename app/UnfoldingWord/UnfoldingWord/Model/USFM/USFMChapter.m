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
#import "LanguageInfoController.h"

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@interface USFMChapter ()
@property (nonatomic, strong) NSArray *elements;
@property (nonatomic, strong) NSString *languageCode;
@end

@implementation USFMChapter

- (NSString *)chapterNumber
{
    USFMElement *element = self.elements[0];
    if (element.isChapter) {
        return element.stringNumber;
    }
    else {
        NSAssert2(NO, @"%s: The first element was not the chapter. Element: %@", __PRETTY_FUNCTION__, element);
        return nil;
    }
}

- (NSAttributedString *)attributedString {
    return [self attributedStringWithSize:19];
}


/// Goes through all the USFMElements in a chapter and composes styled attributed text that is keyed to verses.
- (NSAttributedString *)attributedStringWithSize:(double)size
{
    UIFont *baseFont = [FONT_LIGHT fontWithSize:size];
    UIFont *italicFont = [FONT_LIGHT_ITALIC fontWithSize:size];
    UIFont *superScriptFont = [baseFont fontWithSize:(baseFont.pointSize/1.35)];
    NSDictionary *superScript = @{NSBaselineOffsetAttributeName:@(-1),NSKernAttributeName:@(1), NSFontAttributeName:superScriptFont, (NSString *)kCTSuperscriptAttributeName : @1};
    NSDictionary *normal = @{NSBaselineOffsetAttributeName:@(0), NSFontAttributeName:baseFont};
    NSDictionary *normalItalic = @{NSBaselineOffsetAttributeName:@(0), NSFontAttributeName:italicFont};

    NSMutableAttributedString *string = [NSMutableAttributedString new];
    USFMElement *previousElement = nil;
    NSNumber *verseNumber = nil;

    for (USFMElement *element in self.elements) {
        
        NSString *lastStringCharacter = (string.length > 0) ? [string.string substringWithRange:NSMakeRange(string.string.length-1, 1)] : nil;
        BOOL isLastCharacterReturn = ([lastStringCharacter rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location != NSNotFound);
        
        // Handle verses - can also contain embedded quotes
        if (element.isSelah) {
//            NSAttributedString *para = [[NSAttributedString alloc] initWithString:@"\n" attributes:normal];
//            [string appendAttributedString:para];
//            
            NSParagraphStyle *paraStyle = [self paragraphSelahStyle];
            NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", element.text] attributes:normalItalic];
            [text addAttribute:NSParagraphStyleAttributeName value:paraStyle range:NSMakeRange(0, text.length)];
            [string appendAttributedString:text];
            
//            NSAttributedString *para2 = [[NSAttributedString alloc] initWithString:@"\n" attributes:normal];
//            [string appendAttributedString:para2];
            
        }
        else if (element.isDescriptiveTitle) {
//            NSAttributedString *para = [[NSAttributedString alloc] initWithString:@"\n" attributes:normal];
//            [string appendAttributedString:para];
            NSParagraphStyle *paraStyle = [self paragraphDescriptiveTitleStyle];
            NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n", element.text] attributes:normalItalic];
            [text addAttribute:NSParagraphStyleAttributeName value:paraStyle range:NSMakeRange(0, text.length)];
            [string appendAttributedString:text];
            
//            NSAttributedString *para2 = [[NSAttributedString alloc] initWithString:@"\n" attributes:normal];
//            [string appendAttributedString:para2];
        }
        else if (element.isVerse) {
            
            if (element.text.length > 0) {
                BOOL isShowQuote = (element.isQuote || (previousElement.isQuote && previousElement.text.length == 0));
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
                    if (element.stringNumber.integerValue > 0) { // Add a verse number so we know where the user is.
                        verseNumber = @(element.stringNumber.integerValue);
                        [superscriptString addAttribute:USFM_VERSE_NUMBER value:verseNumber range:NSMakeRange(0, superscriptString.length)];
                    }
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
                if (verseNumber) {
                    [text addAttribute:USFM_VERSE_NUMBER value:verseNumber range:NSMakeRange(0, text.length-1)]; // The 1 is because there's no need to include invisible end elements as part of the verse.
                }
                
                [string appendAttributedString:text];
            }

        }
        // Handle quotes that are NOT verses.
        else if (element.isQuote && element.text.length > 0) {
            NSMutableAttributedString *text = nil;
            if (isLastCharacterReturn == NO) {
                text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@\n", element.text] attributes:normal];
            }
            else {
                text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n", element.text] attributes:normal];
            }
            [text addAttribute:NSParagraphStyleAttributeName value:[self paragraphQuoteStyleWithIndentLevel:element.numberMarker.floatValue] range:NSMakeRange(0, text.length)];
            if (verseNumber) {
                [text addAttribute:USFM_VERSE_NUMBER value:verseNumber range:NSMakeRange(0, text.length-1)]; // The 1 is because there's no need to include invisible end elements as part of the verse.
            }
            [string appendAttributedString:text];
            
        }
        // Handle newline characters - replace all with \n
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
    NSMutableParagraphStyle *paragraphStyle = [self baseParagraphStyle];
    paragraphStyle.firstLineHeadIndent = indent - multiplier;
    paragraphStyle.headIndent = indent;
    return paragraphStyle;
}

- (NSParagraphStyle *)paragraphRegularStyle
{
    return [self baseParagraphStyle];
}

- (NSParagraphStyle *)paragraphSelahStyle
{
    // Create the formatting dictionaries we need
    NSMutableParagraphStyle *paragraphStyle = [self baseParagraphStyle];
    paragraphStyle.firstLineHeadIndent = 0.0f;
    paragraphStyle.paragraphSpacing = 10.0f;
    paragraphStyle.alignment = [self oppositeTextAlignment];
    return paragraphStyle;
}

- (NSParagraphStyle *)paragraphDescriptiveTitleStyle
{
    // Create the formatting dictionaries we need
    NSMutableParagraphStyle *paragraphStyle = [self baseParagraphStyle];
    paragraphStyle.firstLineHeadIndent = 0.0f;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    return paragraphStyle;
}

// Make any changes to the standard paragraph here.
- (NSMutableParagraphStyle *)baseParagraphStyle
{
    // Create the formatting dictionaries we need
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineHeightMultiple = 1.25f;
    paragraphStyle.paragraphSpacing = 0.0f;
    paragraphStyle.firstLineHeadIndent = 15.0f;
    paragraphStyle.headIndent = 0.0f;
    paragraphStyle.alignment = [self regularTextAlignment];
    return paragraphStyle;
}

/// Returns the standard text alignment for the current language (if language code is set; otherwise returns the natural text alignment for the current font/script)
- (NSTextAlignment)regularTextAlignment
{
    if (self.languageCode != nil) {
        return [LanguageInfoController textAlignmentForLanguageCode:self.languageCode];
    }
    else {
        return NSTextAlignmentNatural;
    }
}

/// Returns the standard text alignment for the current language (if language code is set; otherwise returns right)
- (NSTextAlignment)oppositeTextAlignment
{
    if (self.languageCode != nil) {
        NSTextAlignment naturalAlignment = [LanguageInfoController textAlignmentForLanguageCode:self.languageCode];
        if (naturalAlignment == NSTextAlignmentRight) {
            return NSTextAlignmentLeft;
        }
        else {
            return NSTextAlignmentRight;
        }
    }
    else {
        return NSTextAlignmentRight;
    }
}


#pragma mark - Create Chapters

+ (NSArray *)createChaptersFromElements:(NSArray *)elements languageCode:(NSString *)languageCode;
{
    NSMutableArray *chapters = [NSMutableArray new];
    NSMutableArray *chapterElements = nil;
    for (USFMElement *anElement in elements) {
        if (anElement.isChapter) {
            if (chapterElements.count > 0) { // Close out the previous chapter
                [chapters addObject:[self chapterWithElements:chapterElements languageCode:languageCode]];
            }
            chapterElements = [NSMutableArray new];
        }
        // If we haven't reached the first chapter, these elements just go to nil.
        [chapterElements addObject:anElement];
    }
    
    // Take care of the last chapter
    if (chapterElements.count > 0) {
        [chapters addObject:[self chapterWithElements:chapterElements languageCode:languageCode]];
    }
    
    return chapters;
}

#pragma mark - Internal

+ (USFMChapter *)chapterWithElements:(NSArray *)elements languageCode:(NSString *)languageCode;
{
    USFMChapter *chapter = [USFMChapter new];
    chapter.elements = elements;
    chapter.languageCode = languageCode;
    return chapter;
}

@end
