//
//  CommunicationHandler.m
//  UnfoldingWord
//
//  Created by Acts Media Inc. on 25/11/14.
//  Copyright (c) 2014 Distant Shores Media All rights reserved.
//

#import "CommunicationHandler.h"
#import "AFNetworking.h"
#import "Constants.h"
#import "CoreDataClasses.h"
#import "UFWModelImageSync.h"
#import "UFWNotifications.h"

@implementation CommunicationHandler

+ (void)update
{
    [self callLanguageAPI];
}

+ (NSMutableArray *)arrayLanguageDictionariesToUpdate
{
    static NSMutableArray *array = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        array = [NSMutableArray new];
    });
    return array;
}

+(void)callLanguageAPI
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:LANGUAGES_API parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSAssert2([responseObject isKindOfClass:[NSArray class]], @"%s: The response object for languages must be an array, but it was not: %@", __PRETTY_FUNCTION__, responseObject);
        
        NSArray *languageArray = (NSArray *)responseObject;
        BOOL isUpdatedBible = NO;
        for (NSDictionary *languageDictionary in languageArray) {
            NSAssert2([languageDictionary isKindOfClass:[NSDictionary class]], @"%s: The language dictionary was not a dictionary: %@", __PRETTY_FUNCTION__, languageDictionary);
            if ([self doesNeedUpdateForLanguageDictionary:languageDictionary]) {
                isUpdatedBible = YES;
                [UFWLanguage createOrUpdateLanguageWithDictionary:languageDictionary];
                [self queueUpdateForLanguageDictionary:languageDictionary];
            }
        }
        if (! isUpdatedBible) {
            [UFWModelImageSync downloadAllNecessaryImages];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        [self postNotificationDownloadDone];
    }];
}

+ (void)postNotificationDownloadDone
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDownloadEnded object:nil];
}


+ (BOOL)doesNeedUpdateForLanguageDictionary:(NSDictionary *)dictionary
{
    NSString *languageString = [UFWLanguage languageNameForDictionary:dictionary];
    UFWLanguage *language = [UFWLanguage languageForName:languageString];
    if ( ! language) {
        return YES;
    }
    else {
        return [language doesNeedUpdateWithDictionary:dictionary];
    }
}

+ (void)queueUpdateForLanguageDictionary:(NSDictionary *)dictionary
{
    [[self arrayLanguageDictionariesToUpdate] addObject:dictionary];
    [self updateLanguageWithDictionary:dictionary completion:^(BOOL success, NSError *error) {
        NSLog(@"%@", error);
        [[self arrayLanguageDictionariesToUpdate] removeObject:dictionary];
        if ([[self arrayLanguageDictionariesToUpdate] count] == 0) {
            [UFWModelImageSync downloadAllNecessaryImages];
        }
    }];
}

+(void)updateLanguageWithDictionary:(NSDictionary *)languageDictionary completion:(void (^)(BOOL success, NSError *error))completionHandler
{
    NSString *url = [self getChapterAPIString:languageDictionary];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             NSDictionary *bibleDictionary = (NSDictionary *)responseObject;
             NSAssert2([bibleDictionary isKindOfClass:[NSDictionary class]], @"%s: The bible dictionary was not a dictionary: %@", __PRETTY_FUNCTION__, bibleDictionary);
             
             NSString *languageString = [UFWLanguage languageNameForDictionary:languageDictionary];
             UFWLanguage *language = [UFWLanguage languageForName:languageString];
             
             [UFWBible createOrUpdateBibleWithDictionary:bibleDictionary forLanguage:language];
             
             completionHandler(YES, nil);
         });
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             completionHandler(NO, error);
         });
     }];
}

+(NSString *)getChapterAPIString:(NSDictionary *)languageDictionary
{
    NSString *language = [UFWLanguage languageNameForDictionary:languageDictionary];
    return  [NSString stringWithFormat:@"%@%@/obs-%@.json",BASE_URL, language, language];
}

@end
