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

+ (NSArray *)chaptersFromString:(NSString *)usfmString
{
    if ([usfmString isKindOfClass:[NSString class]] && usfmString.length > 0) {
        NSArray *elements = [self parseStringIntoElements:usfmString];
        return [USFMChapter createChaptersFromElements:elements];
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
        
        NSScanner *scanner = [[NSScanner alloc] initWithString:line];
        BOOL firstCode = YES;
        NSString *code = nil;
        NSMutableString *completeText = [NSMutableString new];
        do {
            // Get to the first marker
            if (firstCode == YES) {
                [scanner scanUpToString:@"\\" intoString:NULL];
            }
            
            // Scan the code
            [scanner scanString:@"\\" intoString:NULL];
            if (firstCode == YES) { // the first code is the only one we're using.
                [scanner scanUpToCharactersFromSet:[self usfmBreakCharacterSet] intoString:&code];
            }
            else { // If there are multiple codes on the same line, we're just going to ignore them right now.
                [scanner scanUpToCharactersFromSet:[self usfmBreakCharacterSet] intoString:NULL];
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
        USFMElement *element = [USFMElement newElementWithCodeInfo:code textInfo:completeText];
        if (element != nil) {
            [elements addObject:element];
        }
    }
    
    return elements;
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
