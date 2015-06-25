//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

#import "UWVersion.h"
#import "UWCoreDataClasses.h"

static NSString *const kSlug = @"slug";
static NSString *const kModifiedDate = @"mod";
static NSString *const kName = @"name";
static NSString *const kStatus = @"status";
static NSString *const kTOCItems = @"toc";

NSString *const kNotificationDownloadCompleteForVersion = @"__kNotificationDownloadCompleteForVersion";
NSString *const kNotificationVersionContentDelete = @"__kNotificationVersionContentDelete";
NSString *const kKeyVersionId = @"__kKeyVersionId";

@implementation UWVersion

+ (void)updateVersions:(NSArray *)versions forLanguage:(UWLanguage *)language;
{
    NSArray *existingVersions = language.versions.allObjects;
    
    int sort = 1;
    for (NSDictionary *topDic in versions) {
        UWVersion *version = [self objectForDictionary:topDic withObjects:existingVersions];
        if (version == nil) {
            version = [UWVersion insertInManagedObjectContext:[DWSCoreDataStack managedObjectContext]];
        }
        [version updateWithDictionary:topDic];
        version.language = language;
        version.sortOrderValue = sort++;
    }
}

+ (instancetype)objectForDictionary:(NSDictionary *)dictionary withObjects:(NSArray *)existingObjects
{
    NSString *languageCode = [dictionary objectOrNilForKey:kSlug];
    for (UWVersion *version in existingObjects) {
        if ([version.slug isEqualToString:languageCode]) {
            return version;
        }
    }
    return nil;
}

- (void)updateWithDictionary:(NSDictionary *)dictionary
{
    self.mod = [dictionary objectOrNilForKey:kModifiedDate];
    self.name = [dictionary objectOrNilForKey:kName];
    self.slug = [dictionary objectOrNilForKey:kSlug];
    
    [self updateStatus:[dictionary objectOrNilForKey:kStatus]];
    [self updateTOCItems:[dictionary objectOrNilForKey:kTOCItems]];
}

- (void)updateStatus:(NSDictionary *)dictionary
{
    [UWStatus updateStatus:dictionary forVersion:self];
}

- (void)updateTOCItems:(NSArray *)tocItems
{
    [UWTOC updateTOCitems:tocItems forVersion:self];
}

- (BOOL)deleteAllContent
{
    BOOL success = YES;
    for (UWTOC *toc in self.toc) {
        if ([toc deleteAllContent] == NO) {
            success = NO;
        }
    }
    return success;
}

#pragma mark - Status Tracking

- (BOOL)isAllValid
{
    for (UWTOC *toc in self.toc) {
        if (toc.isContentValidValue == NO) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)isAllDownloaded
{
    for (UWTOC *toc in self.toc) {
        if (toc.isDownloadedValue == NO) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)isAnyDownloaded
{
    for (UWTOC *toc in self.toc) {
        if (toc.isDownloadedValue == YES) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isAnyFailedDownload
{
    for (UWTOC *toc in self.toc) {
        if (toc.isDownloadFailedValue == YES) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isDownloading
{
    return [[self class] isVersionDownloading:self];
}

#pragma mark - Downloading

- (void)downloadWithCompletion:(VersionCompletion)completion
{
    if (self.toc.count == 0) {
        completion(NO, @"No items to download.");
    }
    else {
        [self downloadNextTOC:nil completion:completion];
    }
}

- (void)downloadNextTOC:(UWTOC *)toc completion:(VersionCompletion)completion
{
    // If the TOC is already downloaded and valid, then skip to the next one
    UWTOC *nextTOC = [self nextTOC:toc];
    if ( [nextTOC isDownloadedAndValid]) {
        [self downloadNextTOC:nextTOC completion:completion];
        return;
    }
    else if (nextTOC == nil) {
        completion(YES, nil);
    }
    
    [nextTOC downloadWithCompletion:^(BOOL success) {
        if ([self nextTOC:nextTOC] != nil) {
            [self downloadNextTOC:nextTOC completion:completion];
            if (success == NO) {
                [self.managedObjectContext deleteObject:nextTOC];
            }
            return;
        }
        if (success == NO) {
            [self.managedObjectContext deleteObject:nextTOC];
            [[DWSCoreDataStack managedObjectContext] save:nil];
        }
        if ([self isAllDownloaded]) {
            [[DWSCoreDataStack managedObjectContext] save:nil];
            completion(YES, nil);
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDownloadCompleteForVersion object:nil userInfo:@{kKeyVersionId:self.objectID.URIRepresentation.absoluteString}];
        }
        else {
            [[DWSCoreDataStack managedObjectContext] save:nil];
            completion(NO, @"Internal app error. Some items were not downloaded.");
        }
    }];
}

- (UWTOC *)nextTOC:(UWTOC *)toc
{
    NSArray *tocs = [self sortedTOCs];
    if ([tocs containsObject:toc]) {
        BOOL found = NO;
        for (UWTOC *aTOC in [self sortedTOCs]) {
            if (found) {
                return aTOC;
            }
            if ([aTOC isEqual:toc]) {
                found = YES;
            }
        }
        // We must be on the last TOC.
        return nil;
    }
    else if (tocs.count > 0) {
        return tocs[0];
    }
    else {
        NSAssert2(NO, @"%s: Do not call method when the version has no TOCS!", __PRETTY_FUNCTION__, self);
        return nil;
    }
}

- (NSArray *)sortedTOCs
{
    NSArray *tocArray = self.toc.allObjects;
    return [tocArray sortedArrayUsingComparator:^NSComparisonResult(UWTOC *toc1, UWTOC *toc2) {
        return [toc1.sortOrder compare:toc2.sortOrder];
    }];
}

+ (void)removeVersionDownloading:(UWVersion *)version
{
    [[self downloadDictionary] removeObjectForKey:version.objectID.URIRepresentation.absoluteString];
}

+ (void)addVersionDownloading:(UWVersion *)version
{
    [[self downloadDictionary] setObject:@(YES) forKey:version.objectID.URIRepresentation.absoluteString];
}

+ (BOOL)isVersionDownloading:(UWVersion *)version
{
    NSNumber *downloadNumber = [[self downloadDictionary] objectForKey:version.objectID.URIRepresentation.absoluteString];
    return downloadNumber.boolValue;
}

+ (NSMutableDictionary *)downloadDictionary
{
    static NSMutableDictionary *_dictionaryDownloads = nil;
    if (_dictionaryDownloads == nil) {
        _dictionaryDownloads = [NSMutableDictionary new];
    }
    return _dictionaryDownloads;
}

- (NSDictionary *)jsonRepresention
{
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    
    dictionary[kModifiedDate] = self.mod;
    dictionary[kName] = self.name;
    dictionary[kSlug] = self.slug;
    dictionary[kStatus] = [self.status jsonRepresention];
    
    NSMutableArray *tocItems = [NSMutableArray new];
    for (UWTOC *toc in self.toc) {
        [tocItems addObject:[toc jsonRepresention]];
    }
    dictionary[kTOCItems] = tocItems;
    
    return dictionary;
}


@end
