//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

#import "UWTopContainer.h"
#import "UWCoreDataClasses.h"

static NSString *const kSlug = @"slug";
static NSString *const kTitle = @"title";
static NSString *const kLanguages = @"langs"; // also look for this in Constants.swift
static NSString *const kVersions = @"vers"; // also look for this in Constants.swift
static NSString *const kLanguageCode = @"lc"; // This must match the UWLanguage.h file! (Refactor soon)
static NSString *const kVersionSlug = @"slug"; // This must match the UWVersion.h file! (Refactor soon)

@implementation UWTopContainer

+ (instancetype)topContainerForDictionary:(NSDictionary *)dictionary
{
    NSString *slug = dictionary[kSlug];
    if (slug != nil) {
        for (UWTopContainer *container in [self allObjects]) {
            if ([container.slug isEqualToString:slug]) {
                return container;
            }
        }
    }
    return nil;
}

- (UWLanguage *) languageForDictionary:(NSDictionary *)dictionary
{
    NSArray *languages = dictionary[kLanguages];
    if (languages.count == 1) {
        NSDictionary *langDict = languages[0];
        NSString *lc = langDict[kLanguageCode];
        if ( ! [lc isKindOfClass:[NSString class]]) {
            return nil;
        }
        for (UWLanguage *aLang in self.languages) {
            if ([aLang.lc isEqualToString:lc]) {
                return aLang;
            }
        }
    }
    return nil;
}

- (UWVersion *) versionForDictionary:(NSDictionary *)dictionary
{
    UWLanguage *language = [self languageForDictionary:dictionary];
    if (language == nil) {
        return nil;
    }
    
    NSArray *languages = dictionary[kLanguages];
    if (languages.count == 1) {
        NSDictionary *langDict = [languages firstObject];
        NSArray *versions = langDict[kVersions];
        if (versions.count == 1) {
            NSDictionary *versionDict = [versions firstObject];
            NSString *slug = versionDict[kVersionSlug];
            if ( ! [slug isKindOfClass:[NSString class]]) {
                return nil;
            }
            for (UWVersion *aVersion in language.versions) {
                if ([aVersion.slug isEqualToString:slug]) {
                    return aVersion;
                }
            }
        }
    }
    return nil;
}

+ (void)updateFromArray:(NSArray *)array
{
    NSArray *objects = [self allObjects];
    
    NSInteger sort = objects.count + 1;
    for (NSDictionary *topDic in array) {
        UWTopContainer *container = [self objectForDictionary:topDic withObjects:objects];
        if (container == nil) {
            container = [UWTopContainer insertInManagedObjectContext:[DWSCoreDataStack managedObjectContext]];
            container.sortOrderValue = (int)sort++;
        }
        [container updateWithDictionary:topDic];
    }
    [[DWSCoreDataStack managedObjectContext] save:nil];
}

+ (instancetype)objectForDictionary:(NSDictionary *)dictionary withObjects:(NSArray *)objects
{
    NSString *slug = [dictionary objectOrNilForKey:kSlug];
    for (UWTopContainer *container in objects) {
        if ([container.slug isEqualToString:slug]) {
            return container;
        }
    }
    return nil;
}

+ (instancetype)containerFromDictionary:(NSDictionary *)dictionary
{
    NSString *slug = [dictionary objectOrNilForKey:kSlug];
    for (UWTopContainer *container in [self allObjects]) {
        if ([container.slug isEqualToString:slug]) {
            return container;
        }
    }
    return nil;
}

- (BOOL)isUSFM
{
    UWLanguage *language = [self.languages anyObject];
    UWVersion *version = [language.versions anyObject];
    UWTOC *toc = [version.toc anyObject];
    return toc.isUSFMValue;
}

- (void)updateWithDictionary:(NSDictionary *)dictionary
{
    self.slug = [dictionary objectOrNilForKey:kSlug];
    self.title = [dictionary objectOrNilForKey:kTitle];
    [self updateLanguages:[dictionary objectOrNilForKey:kLanguages]];
}

- (void)updateLanguages:(NSArray *)languages
{
    [UWLanguage updateLanguages:languages forContainer:self];
}

- (NSArray *)sortedLanguages
{
    NSArray *langArray = self.languages.allObjects;
    return [langArray sortedArrayUsingComparator:^NSComparisonResult(UWLanguage *lang1, UWLanguage *lang2) {
        return [lang1.sortOrder compare:lang2.sortOrder];
    }];
}

- (NSDictionary *)jsonRepresentionWithoutLanguages
{
    NSMutableDictionary *topDictionary = [NSMutableDictionary new];
    topDictionary[kSlug] = self.slug;
    topDictionary[kTitle] = self.title;
    return topDictionary;
}

@end
