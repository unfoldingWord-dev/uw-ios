//
//  USFMElement.m
//  UnfoldingWord
//
//  Created by David Solberg on 4/27/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

#import "USFMElement.h"
#import "NSString+Trim.h"

static NSString *const codeParagraph = @"p";
static NSString *const codeVerse = @"v";
static NSString *const codeChapter = @"c";
static NSString *const codeQuote = @"q";
static NSString *const codeLineBreak = @"b";
static NSString *const codeSelah = @"qs";
static NSString *const codeDescriptiveTitle = @"d";
static NSString *const codeIndividualChapterTitle = @"cl";
static NSString *const codeFootnote = @"f";

@interface USFMElement ()
@property (nonatomic, strong) NSArray *codes;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *stringNumber;
@property (nonatomic, strong) NSNumber *numberMarker;
@end

@implementation USFMElement

#pragma mark - Outside Methods

+ (USFMElement *)newElementWithCodeInfo:(NSArray *)codeInfo textInfo:(NSString *)textInfo
{
    USFMElement *element = [USFMElement new];
    [element parseCodeInfo:codeInfo];
    if ([element containsAtLeastOneValidCode]) {
        [element parseTextInfo:textInfo];
        return element;
    }
    else {
        return nil;
    }
}

- (BOOL)appendText:(NSString *)text
{
    if ([text isKindOfClass:[NSString class]] == NO || [text trimSpacesBeforeAfter].length == 0) {
        return NO;
    }
    else if (self.isVerse || self.isQuote) {
        text = [text trimSpacesBeforeAfter];
        self.text = [self.text stringByAppendingFormat:@" %@", text];
        return YES;
    }
    else {
        return NO;
    }
}

- (BOOL)isChapter
{
    return [self hasCode:codeChapter];
}

- (BOOL)isVerse
{
    return [self hasCode:codeVerse];
}

- (BOOL)isDescriptiveTitle {
    return [self hasCode:codeDescriptiveTitle];
}

- (BOOL)isSelah {
    return [self hasCode:codeSelah];
}

- (BOOL)isParagraph
{
    return self.codes.count == 1 && [self hasCode:codeParagraph];
}

- (BOOL)isLineBreak
{
    return self.codes.count == 1 && [self hasCode:codeLineBreak];
}

- (BOOL)isQuote
{
    return [self hasCode:codeQuote];
}

- (BOOL)isFootNote {
    return [self hasCode:codeFootnote];
}

- (BOOL)isChapterTitle {
    return [self hasCode:codeIndividualChapterTitle];
}

- (BOOL)hasCode:(NSString *)code
{
    for (NSString *aCode in self.codes) {
        if ([code isEqualToString:aCode]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Parsing

- (void) parseCodeInfo:(NSArray *)codes
{
    NSMutableArray *finalCodes = [NSMutableArray new];
    
    for (NSString *code in codes) {
        if (code.length <= 1) {
            [finalCodes addObject:code];
        }
        else {
            NSScanner *scanner = [NSScanner scannerWithString:code];
            NSString *codePart = nil;
            [scanner scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&codePart];
            if (scanner.scanLocation == code.length ) {
                [finalCodes addObject:code];
            }
            else {
                NSString *numberPart = [code substringWithRange:NSMakeRange(scanner.scanLocation, code.length - scanner.scanLocation)];
                if (numberPart.integerValue > 0) {
                    self.numberMarker = @(numberPart.integerValue);
                }
                [finalCodes addObject:codePart];
            }
        }
    }
    self.codes = finalCodes;
}

- (void)parseTextInfo:(NSString *)text
{
    text = [text trimSpacesBeforeAfter];
    
    // If we expect to get a number (like a verse), then put that into a separate numberString
    if ( [self expectsNumber] && text.length > 0 ) {
        
        NSScanner *scanner = [NSScanner scannerWithString:text];
        NSString *numberInfo = nil;
        [scanner scanCharactersFromSet:[self numberInfoSet] intoString:&numberInfo];
        numberInfo = [[numberInfo componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] componentsJoinedByString:@""];
        if (numberInfo.length > 0) {
            self.stringNumber = numberInfo;
            text = [text substringWithRange:NSMakeRange(scanner.scanLocation, text.length - scanner.scanLocation)];
        }
    }
    self.text = text;
}

#pragma mark - Helpers

- (NSCharacterSet *)numberInfoSet
{
    NSCharacterSet *infoSet = nil;
    if ( infoSet == nil) {
        NSMutableCharacterSet *numberSet = [[NSCharacterSet decimalDigitCharacterSet] mutableCopy];
        [numberSet formUnionWithCharacterSet:[NSCharacterSet whitespaceCharacterSet]];
        [numberSet formUnionWithCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@"-"]];
        infoSet = [numberSet copy];
    }
    return infoSet;
}

// Right now, only a chapter and verse expects a number at the start of the text portion.
- (BOOL)expectsNumber
{
    if ([self isVerse] || [self isChapter]) {
        return YES;
    }
    return NO;
}

// Return codes we want to use.
- (BOOL)containsAtLeastOneValidCode
{
    for (NSString *keeperCode in [self validCodes]) {
        for (NSString *existingCode in self.codes) {
            if ([keeperCode isEqualToString:existingCode]) {
                return YES;
            }
        }
    }
    return NO;
}

- (NSArray *)validCodes
{
    return @[codeParagraph, codeVerse, codeFootnote, codeChapter, codeQuote, codeLineBreak, codeSelah, codeDescriptiveTitle, codeIndividualChapterTitle];
}

@end
