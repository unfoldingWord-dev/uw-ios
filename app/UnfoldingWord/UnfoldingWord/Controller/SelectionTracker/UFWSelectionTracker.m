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

static NSString *const kKeyIsShowingSide = @"isShowingSide";
static NSString *const kKeyShowingSideOBS = @"isShowingSide_OBS";
static NSString *const kKeyTOCUSFM = @"toc_USFM";
static NSString *const kKeyTOCUSFMSide = @"toc_side_USFM";
static NSString *const kKeyTOCJSON = @"toc_JSON";
static NSString *const kKeyTOCJSONSide = @"toc_JSON_side";
static NSString *const kKeyChapterUSFM = @"chapter_USFM";
static NSString *const kKeyChapterJSON = @"chapter_JSON";
static NSString *const kDictionaryName = @"selection_tracker_dictionary.plist"; // where we store all this.
static NSString *const kKeyFrameJSON = @"frame_JSON";
static NSString *const kKeyUrlString = @"url_string";
static NSString *const kKeyTopContainer = @"top_container";
static NSString *const kKeyFontPointSize = @"font_point_size";

static CGFloat const kMinimumFontSize = 5.0f;
static CGFloat const kDefaultFontSize = 18.0f;

@implementation UFWSelectionTracker

#pragma mark - Setters

+ (void)setIsShowingSide:(BOOL)isShowingSide
{
    [self setObject:@(isShowingSide) forKey:kKeyIsShowingSide];
}

+ (void)setIsShowingSideOBS:(BOOL)isShowingSide
{
    [self setObject:@(isShowingSide) forKey:kKeyShowingSideOBS];
}

+ (void)setFontPointSize:(CGFloat)pointSize
{
    [self setObject:@(pointSize) forKey:kKeyFontPointSize];
}

+ (void)setUSFMTOC:(UWTOC *)toc
{
    [self setObject:toc.objectID.URIRepresentation.absoluteString forKey:kKeyTOCUSFM];
}

+ (void)setUSFMTOCSide:(UWTOC *)toc
{
    [self setObject:toc.objectID.URIRepresentation.absoluteString forKey:kKeyTOCUSFMSide];
}

+ (void)setJSONTOC:(UWTOC *)toc
{
    [self setObject:toc.objectID.URIRepresentation.absoluteString forKey:kKeyTOCJSON];
}

+ (void)setJSONTOCSide:(UWTOC * __nullable)toc;
{
    [self setObject:toc.objectID.URIRepresentation.absoluteString forKey:kKeyTOCJSONSide];
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

+ (BOOL)isShowingSide {
    return [self numberForKey:kKeyIsShowingSide] == 0 ? NO : YES;
}

+ (BOOL)isShowingSideOBS {
    return [self numberForKey:kKeyShowingSideOBS] == 0 ? NO : YES;
}

+ (UWTOC *)TOCforUSFM;
{
    NSString *absoluteUrl = [[self dictionary] objectForKey:kKeyTOCUSFM];
    return (UWTOC *)[self managedObjectforURLString:absoluteUrl];
}

+ (UWTOC *)TOCforUSFMSide
{
    NSString *absoluteUrl = [[self dictionary] objectForKey:kKeyTOCUSFMSide];
    return (UWTOC *)[self managedObjectforURLString:absoluteUrl];

}

+ (UWTOC *)TOCforJSON;
{
    NSString *absoluteUrl = [[self dictionary] objectForKey:kKeyTOCJSON];
    return (UWTOC *)[self managedObjectforURLString:absoluteUrl];
}

+ (UWTOC *)TOCforJSONSide
{
    NSString *absoluteUrl = [[self dictionary] objectForKey:kKeyTOCJSONSide];
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
    return [self oneBoundedNumberForKey:kKeyChapterUSFM];
}

+ (NSInteger)chapterNumberJSON;
{
    return [self oneBoundedNumberForKey:kKeyChapterJSON];
}

+ (NSInteger)frameNumberJSON
{
    return [self oneBoundedNumberForKey:kKeyFrameJSON];
}

+ (CGFloat)fontPointSize {
    CGFloat savedSize = [self numberForKey:kKeyFontPointSize];
    CGFloat finalSize = (savedSize >= kMinimumFontSize) ? savedSize : kDefaultFontSize;
    return finalSize;
}

+ (NSInteger)oneBoundedNumberForKey:(NSString *)key {
    NSInteger number = [self numberForKey:key];
    if (number > 0) {
        return number;
    }
    else {
        return 1;
    }
}

+ (NSInteger)numberForKey:(NSString *)key
{
    NSNumber *number = [[self dictionary] objectForKey:key];
    if ([number isKindOfClass:[NSNumber class]]) {
        return number.integerValue;
    }
    else {
        return 0;
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
