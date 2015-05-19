//
//  UFWSelectionTracker.m
//  UnfoldingWord
//
//  Created by David Solberg on 5/12/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

#import "UFWSelectionTracker.h"
#import "NSString+Trim.h"
#import "UWCoreDataClasses.h"

static NSString *const kBaseAPI = @"https://api.unfoldingword.org/uw/txt/2/catalog.json";

static NSString *const kKeyTOCUSFM = @"toc_USFM";
static NSString *const kKeyTOCJSON = @"toc_JSON";
static NSString *const kKeyChapterUSFM = @"chapter_USFM";
static NSString *const kKeyChapterJSON = @"chapter_JSON";
static NSString *const kDictionaryName = @"selection_tracker_dictionary.plist";
static NSString *const kKeyFrameJSON = @"frame_JSON";
static NSString *const kKeyUrlString = @"url_string";
static NSString *const kKeyTopContainer = @"top_container";

@implementation UFWSelectionTracker

#pragma mark - Setters

+ (void)setUSFMTOC:(UWTOC *)toc
{
    [self setObject:toc.objectID.URIRepresentation.absoluteString forKey:kKeyTOCUSFM];
}

+ (void)setJSONTOC:(UWTOC *)toc
{
    [self setObject:toc.objectID.URIRepresentation.absoluteString forKey:kKeyTOCJSON];
}

+ (void)setChapterJSON:(NSInteger)chapter
{
    [self setObject:@(chapter) forKey:kKeyChapterJSON];
}

+ (void)setChapterUSFM:(NSInteger)chapter
{
    [self setObject:@(chapter) forKey:kKeyChapterUSFM];
}

+ (void)setFrameJSON:(NSInteger)frame
{
    [self setObject:@(frame) forKey:kKeyFrameJSON];
}

+ (void)setUrlString:(NSString *)url
{
    [self setObject:url forKey:kKeyUrlString];
}

+ (void)setTopContainer:(UWTopContainer *)topContainer
{
    [self setObject:topContainer.objectID.URIRepresentation.absoluteString forKey:kKeyTopContainer];
}

#pragma mark - Getters

+ (UWTOC *)TOCforUSFM;
{
    NSString *absoluteUrl = [[self dictionary] objectForKey:kKeyTOCUSFM];
    return (UWTOC *)[self managedObjectforURLString:absoluteUrl];
}

+ (UWTOC *)TOCforJSON;
{
    NSString *absoluteUrl = [[self dictionary] objectForKey:kKeyTOCJSON];
    return (UWTOC *)[self managedObjectforURLString:absoluteUrl];
}

+ (NSManagedObject *)managedObjectforURLString:(NSString *)urlString
{
    if ( [urlString isKindOfClass:[NSString class]] == NO) {
        return nil;
    }
    NSURL *url = [NSURL URLWithString:urlString];
    if ([url isKindOfClass:[NSURL class]] == NO) {
        NSAssert2(NO, @"%s: No url for string %@", __PRETTY_FUNCTION__, urlString);
        return nil;
    }
    
    NSManagedObjectID *tocID = [[DWSCoreDataStack persistentStoreCoordinator] managedObjectIDForURIRepresentation:url];
    if (tocID == nil) {
        NSAssert2(NO, @"%s: No object id was found for url %@", __PRETTY_FUNCTION__, url);
        return nil;
    }
    NSManagedObject *toc = [[DWSCoreDataStack managedObjectContext] objectWithID:tocID];
    if ([toc isKindOfClass:[NSManagedObject class]] == NO) {
        NSAssert2(NO, @"%s: The returned object was not a managed object: %@", __PRETTY_FUNCTION__, toc);
        return nil;
    }
    return toc;
}

+ (NSInteger)chapterNumberUSFM;
{
    return [self numberForKey:kKeyChapterUSFM];
}

+ (NSInteger)chapterNumberJSON;
{
    return [self numberForKey:kKeyChapterJSON];
}

+ (NSInteger)frameNumberJSON
{
    return [self numberForKey:kKeyFrameJSON];
}

+ (NSInteger)numberForKey:(NSString *)key
{
    NSNumber *number = [[self dictionary] objectForKey:key];
    if ([number isKindOfClass:[NSNumber class]]) {
        return number.integerValue;
    }
    else {
        return 1;
    }
}

+ (NSString *)urlString
{
    NSString *url = [[self dictionary] objectForKey:kKeyUrlString];
    if ([url isKindOfClass:[NSString class]]) {
        return url;
    }
    else {
        return kBaseAPI;
    }
}

+ (UWTopContainer *)topContainer
{
    NSString *absoluteUrl = [[self dictionary] objectForKey:kKeyTopContainer];
    return (UWTopContainer *)[self managedObjectforURLString:absoluteUrl];
}

#pragma mark - Helpers

+ (void) setObject:(id)object forKey:(NSString *)key
{
    if (object == nil) {
        [[self dictionary] removeObjectForKey:key];
    }
    else {
        [[self dictionary] setObject:object forKey:key];
    }
    [[self dictionary] writeToFile:[self filePath] atomically:YES];
}

+ (NSMutableDictionary *)dictionary
{
    static NSMutableDictionary *_dictionary = nil;
    if (_dictionary == nil) {
        _dictionary = [[NSDictionary dictionaryWithContentsOfFile:[self filePath]] mutableCopy];
        if (_dictionary == nil) {
            _dictionary = [NSMutableDictionary new];
        }
    }
    return _dictionary;
}

+ (NSString *)filePath
{
    return [[NSString documentsDirectory] stringByAppendingPathComponent:kDictionaryName];
}


@end
