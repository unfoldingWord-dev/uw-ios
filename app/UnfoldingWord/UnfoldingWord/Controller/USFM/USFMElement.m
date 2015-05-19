//
//  USFMElement.m
//  UnfoldingWord
//
//  Created by David Solberg on 4/27/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

#import "USFMElement.h"
#import "NSString+Trim.h"

@interface USFMElement ()
@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *stringNumber;
@property (nonatomic, strong) NSNumber *numberMarker;
@end

@implementation USFMElement

#pragma mark - Outside Methods

+ (USFMElement *)newElementWithCodeInfo:(NSString *)codeInfo textInfo:(NSString *)textInfo
{
    if ([self isUsingCode:codeInfo] == NO) {
        return nil;
    }
    else {
        USFMElement *element = [USFMElement new];
        [element parseCodeInfo:codeInfo];
        [element parseTextInfo:textInfo];
        return element;
    }
}

- (BOOL)isChapter
{
    return [self.code isEqualToString:@"c"];
}

- (BOOL)isVerse
{
    return [self.code isEqualToString:@"v"];
}

- (BOOL)isParagraph
{
    return [self.code isEqualToString:@"p"];
}

#pragma mark - Parsing

- (void) parseCodeInfo:(NSString *)code
{
    if (code.length <= 1) {
        self.code = code;
        return;
    }
    else {
        NSScanner *scanner = [NSScanner scannerWithString:code];
        NSString *codePart = nil;
        [scanner scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&codePart];
        if (scanner.scanLocation == codePart.length ) {
            self.code = code;
            return;
        }
        else {
            NSString *numberPart = [code substringWithRange:NSMakeRange(scanner.scanLocation, code.length - scanner.scanLocation)];
            if (numberPart.integerValue > 0) {
                self.numberMarker = @(numberPart.integerValue);
            }
            self.code = codePart;
        }
    }
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
    if ([self.code isEqualToString:@"v"] || [self.code isEqualToString:@"c"]) {
        return YES;
    }
    return NO;
}

// Return codes we want to use.
+ (BOOL)isUsingCode:(NSString *)code
{
    NSArray *codes = @[@"p", @"v", @"c"];
    for (NSString *keeperCode in codes) {
        if ([keeperCode isEqualToString:code]) {
            return YES;
        }
    }
    return NO;
}

@end
