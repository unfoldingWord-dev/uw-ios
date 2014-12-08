//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

#import "UFWLanguage.h"
#import "DWSCoreDataStack.h"
#import "NSDictionary+DWSNull.h"
#import "Utils.h"

static NSString *const k_KEY_LANGUAGE_STRING = @"string";
static NSString *const k_KEY_LANGUAGE = @"language";
static NSString *const k_KEY_DIRECTION = @"direction";
static NSString *const k_KEY_DATE_MODIFIED = @"date_modified";
static NSString *const k_KEY_CHECKING_ENTITY = @"checking_entity";
static NSString *const k_KEY_CHECHING_LEVEL = @"checking_level";
static NSString *const k_KEY_PUBLISH_DATE = @"publish_date";
static NSString *const k_KEY_VERSION = @"version";
static NSString *const k_KEY_STATUS_FOLDER = @"status";

@implementation UFWLanguage

+ (NSString *)languageNameForDictionary:(NSDictionary *)dictionary
{
    return [dictionary objectOrNilForKey:k_KEY_LANGUAGE];
}

- (BOOL)doesNeedUpdateWithDictionary:(NSDictionary *)dictionary
{
    NSString *currentDateString = self.date_modified;
    NSString *dictionaryDateString = [dictionary objectOrNilForKey:k_KEY_DATE_MODIFIED];
    
    NSDate *currentDate = [Utils dateWithString:currentDateString withFormatterString:@"YYYYMMdd" timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate *dictionaryDate = [Utils dateWithString:dictionaryDateString withFormatterString:@"YYYYMMdd" timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    if ([dictionaryDate compare:currentDate] == NSOrderedDescending) {
        return YES;
    }
    else {
        return NO;
    }
}

+ (void)createOrUpdateLanguageWithDictionary:(NSDictionary *)dictionary
{
    NSString *languageName = [self languageNameForDictionary:dictionary];
    
    UFWLanguage *language = nil;
    if ([languageName isKindOfClass:[NSString class]]) {
        language = [self languageForName:languageName];
    }
    else {
        NSAssert2(NO, @"%s: Could not get language string from dictionary: %@", __PRETTY_FUNCTION__, dictionary);
        return;
    }
    
    if ( ! language) {
        language = [UFWLanguage insertInManagedObjectContext:[DWSCoreDataStack managedObjectContext]];
    }
    
    [self updateLanguage:language withDictionary:dictionary];
}

+ (void)updateLanguage:(UFWLanguage *)language withDictionary:(NSDictionary *)dictionary
{
    language.language_string = [dictionary objectOrNilForKey:k_KEY_LANGUAGE_STRING];
    language.language = [self languageNameForDictionary:dictionary];
    language.direction = [dictionary objectForKey:k_KEY_DIRECTION];
    language.date_modified = [dictionary objectOrNilForKey:k_KEY_DATE_MODIFIED];
    
    NSDictionary *statusDictionary = [dictionary objectOrNilForKey:k_KEY_STATUS_FOLDER];
    
    language.publish_date = [statusDictionary objectOrNilForKey:k_KEY_PUBLISH_DATE];
    language.version = [statusDictionary objectOrNilForKey:k_KEY_VERSION];
    language.checking_entity = [statusDictionary objectOrNilForKey:k_KEY_CHECKING_ENTITY];
    language.checking_level = [statusDictionary objectOrNilForKey:k_KEY_CHECHING_LEVEL];
    language.publish_date = [statusDictionary objectOrNilForKey:k_KEY_PUBLISH_DATE];
    
    NSError *error;
    [[DWSCoreDataStack managedObjectContext] save:&error];
    NSAssert2( ! error, @"%s: Error saving a language: %@",__PRETTY_FUNCTION__, error);
}

+(UFWLanguage *)languageForName:(NSString *)language
{
    NSManagedObjectContext *managedObjectContext = [DWSCoreDataStack managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Language"];
    NSPredicate *languagePredicate = [NSPredicate predicateWithFormat:@"language = %@", language];
    [request setPredicate:languagePredicate];
    
    // Execute the fetch.
    NSError *error;
    NSArray *fetchResults = [managedObjectContext executeFetchRequest:request error:&error];
    NSAssert2( ! error, @"%s: Error fetching languages: %@", __PRETTY_FUNCTION__, error);
    
    if ([fetchResults count] == 1) {
        return fetchResults[0];
    }
    else {
        return nil;
    }
}

+(NSArray *)allLanguages
{
    NSManagedObjectContext *managedObjectContext = [DWSCoreDataStack managedObjectContext];
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"language_string" ascending:YES selector:@selector(compare:)];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Language"];
    [request setSortDescriptors:@[sortDescriptor]];
    
    // Execute the fetch.
    NSError *error;
    NSArray *fetchResults = [managedObjectContext executeFetchRequest:request error:&error];
    NSAssert2( ! error, @"%s: Error fetching languages: %@", __PRETTY_FUNCTION__, error);
    
    return fetchResults;
}

- (void)setAsSelectedLanguage
{
    for (UFWLanguage *language in [UFWLanguage allLanguages]) {
        if ([language isEqual:self]) {
            language.isSelected = @(YES);
        }
        else {
            language.isSelected = @(NO);
        }
    }
}


@end
