//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

#import "UWLanguage.h"
#import "UWCoreDataClasses.h"

static NSString *const kLanguageCode = @"lc";
static NSString *const kModifiedDate = @"mod";
static NSString *const kVersions = @"vers";

@implementation UWLanguage

+ (void)updateLanguages:(NSArray *)languages forContainer:(UWTopContainer *)container
{
    NSArray *existingLanguages = container.languages.allObjects;
    
    int sort = 1;
    for (NSDictionary *langDic in languages) {
        UWLanguage *language = [self objectForDictionary:langDic withObjects:existingLanguages];
        if (language == nil) {
            language = [UWLanguage insertInManagedObjectContext:[DWSCoreDataStack managedObjectContext]];
        }
        [language updateWithDictionary:langDic];
        language.topContainer = container;
        language.sortOrderValue = sort++;
    }
}

+ (instancetype)objectForDictionary:(NSDictionary *)dictionary withObjects:(NSArray *)existingObjects
{
    NSString *languageCode = [dictionary objectOrNilForKey:kLanguageCode];
    for (UWLanguage *language in existingObjects) {
        if ([language.lc isEqualToString:languageCode]) {
            return language;
        }
    }
    return nil;
}

- (void)updateWithDictionary:(NSDictionary *)dictionary
{
    self.mod = [dictionary objectOrNilForKey:kModifiedDate];
    self.lc = [dictionary objectOrNilForKey:kLanguageCode];
    
    [self updateVersions:[dictionary objectOrNilForKey:kVersions]];
}

- (void)updateVersions:(NSArray *)versions
{
    [UWVersion updateVersions:versions forLanguage:self];
}

- (NSArray *)sortedVersions
{
    NSArray *versionArray = self.versions.allObjects;
    return [versionArray sortedArrayUsingComparator:^NSComparisonResult(UWVersion *v1, UWVersion *v2) {
        return [v1.sortOrder compare:v2.sortOrder];
    }];
}

- (NSDictionary *)jsonRepresentionWithoutVersions
{
    NSMutableDictionary *topDictionary = [NSMutableDictionary new];
    topDictionary[kModifiedDate] = self.mod;
    topDictionary[kLanguageCode] = self.lc;
    return topDictionary;
}

@end
