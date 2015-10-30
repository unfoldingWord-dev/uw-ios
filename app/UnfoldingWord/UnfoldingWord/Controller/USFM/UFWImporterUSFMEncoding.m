//
//  UFWImporterUSFMEncoding.m
//  UnfoldingWord
//
//  Created by David Solberg on 2/24/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

#import "UFWImporterUSFMEncoding.h"
#import "USFMCoding.h"
#import "USFMElement.h"
#import "NSString+Trim.h"

@implementation UFWImporterUSFMEncoding

+ (NSArray *)chaptersFromString:(NSString *)usfmString languageCode:(NSString *)languageCode
{
    if ([usfmString isKindOfClass:[NSString class]] && usfmString.length > 0) {
        NSArray *elements = [self parseStringIntoElements:usfmString];
        return [USFMChapter createChaptersFromElements:elements languageCode:languageCode];
    }
    else {
        return nil;
    }
}

+ (NSArray *)parseStringIntoElements:(NSString *)usfmString
{
    // Separating into lines because sometimes codes appear mid-line. Ignore mid-line codes for now and just concatenate the text.
    NSArray *lines = [usfmString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    NSMutableArray *elements = [NSMutableArray new];
    
    for (NSString *line in lines) {
        
        // Skip over lines that don't have a code. If possible add them to the prior quote or verse. If not, delete them.
        if (elements.count > 0 && [self didRequireFixMissingCodeForLine:line previousElement:elements.lastObject]) {
            continue;
        }
        
        NSScanner *scanner = [[NSScanner alloc] initWithString:line];
        BOOL firstCode = YES;
        NSString *code = nil;
        NSMutableString *completeText = [NSMutableString new];
        NSMutableArray *codes = [NSMutableArray new];
        do {
            
            // Get to the first marker
            if (firstCode == YES) {
                [scanner scanUpToString:@"\\" intoString:NULL];
            }
            
            // Scan the code
            [scanner scanString:@"\\" intoString:NULL];
            code = nil;
            [scanner scanUpToCharactersFromSet:[self usfmBreakCharacterSet] intoString:&code];
            
            if (code != nil) {
                [codes addObject:code];
            }
            
            // Remove stop characters after the code.
            [scanner scanCharactersFromSet:[self usfmAbsorbCharacterSet] intoString:NULL];
            
            // Now get all text before the next code
            NSString *sourceText = nil;
            [scanner scanUpToString:@"\\" intoString:&sourceText];
            
            // Append the source text to the full text
            sourceText = [sourceText trimSpacesBeforeAfter];
            if (sourceText.length > 0) {
                [completeText appendFormat:@" %@", sourceText];
            }
            
            firstCode = NO;
            
        } while ( ! [scanner isAtEnd]);
        
        // Now create one element with the line, ignoring mid-line codes
        USFMElement *element = [USFMElement newElementWithCodeInfo:codes textInfo:completeText];
        if (element != nil) {
            [elements addObject:element];
        }
    }
    
    return elements;
}

+ (BOOL)didRequireFixMissingCodeForLine:(NSString *)line previousElement:(USFMElement *)element
{
    if ([line rangeOfString:@"\\"].location != NSNotFound) {
        return NO;
    }
    else if (element.isVerse || element.isQuote) {
        [element appendText:line];
    }
    return YES;
}

+ (NSCharacterSet *)usfmBreakCharacterSet
{
    static NSCharacterSet *usfmBreak = nil;
    if ( ! usfmBreak) {
        // Either a " ", "*" or "\" character signal the end of the code
        usfmBreak = [NSCharacterSet characterSetWithCharactersInString:@"* \\"];
    }
    return usfmBreak;
}

+ (NSCharacterSet *)usfmAbsorbCharacterSet
{
    static NSCharacterSet *usfmAbsorb = nil;
    if ( ! usfmAbsorb) {
        // Either a " ", "*" character at the end of a code should be absorbed
        usfmAbsorb = [NSCharacterSet characterSetWithCharactersInString:@"* "];
    }
    return usfmAbsorb;
}

@end
