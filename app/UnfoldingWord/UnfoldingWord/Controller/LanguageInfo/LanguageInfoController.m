//
//  LanguageInfoController.m
//  UnfoldingWord
//
//  Created by David Solberg on 5/7/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

#import "LanguageInfoController.h"
#import "UFWLanguageInfo.h"

@implementation LanguageInfoController

+ (NSTextAlignment)textAlignmentForLanguageCode:(NSString *)lc
{
    UFWLanguageInfo *langInfo = [self languageInfoForCode:lc];
    if ([langInfo.directionReading isEqualToString:@"ltr"]) {
        return NSTextAlignmentLeft;
    }
    else {
        return NSTextAlignmentRight;
    }
}

+ (NSString *)nameForLanguageCode:(NSString *)lc;
{
    UFWLanguageInfo *langInfo = [self languageInfoForCode:lc];
    return langInfo.name;
}

+ (UFWLanguageInfo *)languageInfoForCode:(NSString *)lc
{
    if (lc.length == 0) {
        return nil;
    }
    for (UFWLanguageInfo *langInfo in [self arrayLanguageItems]) {
        if ([langInfo.languageCode isEqualToString:lc]) {
            return langInfo;
        }
    }
    return nil;
}

+ (NSArray *)arrayLanguageItems
{
    static NSArray *languageItems = nil;
    if (languageItems == nil) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"languageInfo" ofType:@"plist"];
        NSArray *dictionaryArray = [NSArray arrayWithContentsOfFile:filePath];
        NSMutableArray *langArray = [NSMutableArray new];
        for (NSDictionary *dictionary in dictionaryArray) {
            UFWLanguageInfo *langInfo = [UFWLanguageInfo modelObjectWithDictionary:dictionary];
            if (langInfo) {
                [langArray addObject:langInfo];
            }
        }
        languageItems = langArray;
    }
    return languageItems;
}

@end
