//
//  UFWModelImageSync.m
//  UnfoldingWord
//
//  Created by David Solberg on 12/5/14.
//  Copyright (c) 2014 Distant Shores Media All rights reserved.
//

#import "UFWModelImageSync.h"
#import "CoreDataClasses.h"
#import "DWImageGetter.h"
#import "UFWNotifications.h"

@implementation UFWModelImageSync

+ (void)downloadAllNecessaryImages
{
    NSArray *urlImageStringArray = [self stringsToDownload];
    
    if ([urlImageStringArray count] == 0) {
        [self postNotificationDownloadDone];
        return;
    }
    else {
        [[self arrayOfStringsToDownload] addObjectsFromArray:urlImageStringArray];
        for (NSString *string in urlImageStringArray) {
            [[DWImageGetter sharedInstance] retrieveImageWithURLString:string completionBlock:^(NSString *originalUrl, UIImage *image) {
                [self removeString:string];
                if ([self arrayOfStringsToDownload].count == 0) {
                    [self postNotificationDownloadDone];
                }
            }];
        }
    }
}

+ (void)postNotificationDownloadDone
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDownloadEnded object:nil];
}

+ (NSMutableArray *)arrayOfStringsToDownload
{
    static NSMutableArray *stringsArray = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        stringsArray = [NSMutableArray new];
    });
    return stringsArray;
}

+ (void)removeString:(NSString *)string
{
    __block NSInteger index = -1;
    [[self arrayOfStringsToDownload] enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(NSString *existingString, NSUInteger idx, BOOL *stop) {
        if ([existingString isEqualToString:string]) {
            index = idx;
            *stop = YES;
        }
    }];
    
    if (index >= 0) {
        [[self arrayOfStringsToDownload] removeObjectAtIndex:index];
    }
    else {
        NSLog(@"Could not find string %@ in array %@", string, [self arrayOfStringsToDownload]);
    }
}

+(NSArray *)stringsToDownload
{
    NSMutableArray *urlsToDownload = [NSMutableArray new];
    
//    for (UFWLanguage *language in [UFWLanguage allLanguages]) {
//        for (UFWChapter *chapter in language.bible.chapters) {
//            for (UFWFrame *frame in chapter.frames) {
//                NSString *urlImageString = frame.imageUrl;
//                if ( ! [[DWImageGetter sharedInstance] fileExistsForUrlString:urlImageString]) {
//                    if ( ! [self array:urlsToDownload containsString:urlImageString]) {
//                        [urlsToDownload addObject:urlImageString];
//                    }
//                }
//            }
//        }
//    }
    return [urlsToDownload copy];
}

+ (BOOL)array:(NSArray *)array containsString:(NSString *)string
{
    __block BOOL response = NO;
    [array enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(NSString *existingString, NSUInteger idx, BOOL *stop) {
        if ([existingString isEqualToString:string]) {
            response = YES;
            *stop = YES;
        }
    }];
    return response;
}

@end
