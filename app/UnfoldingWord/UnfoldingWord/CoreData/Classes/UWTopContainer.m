//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

#import "UWTopContainer.h"
#import "UWCoreDataClasses.h"

static NSString *const kSlug = @"slug";
static NSString *const kTitle = @"title";
static NSString *const kLanguages = @"langs";

@interface UWTopContainer ()

@end

@implementation UWTopContainer

+ (void)updateFromArray:(NSArray *)array
{
    NSArray *objects = [self allObjects];
    
    int sort = 1;
    for (NSDictionary *topDic in array) {
        UWTopContainer *container = [self objectForDictionary:topDic withObjects:objects];
        if (container == nil) {
            container = [UWTopContainer insertInManagedObjectContext:[DWSCoreDataStack managedObjectContext]];
        }
        [container updateWithDictionary:topDic];
        container.sortOrderValue = sort++;
    }
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

@end
