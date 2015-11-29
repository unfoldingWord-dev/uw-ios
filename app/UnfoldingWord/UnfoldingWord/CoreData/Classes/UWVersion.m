//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

#import "UWVersion.h"
#import "UWCoreDataClasses.h"
#import "Constants.h"

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

- (NSString *)filename
{
    UWTOC *toc = self.toc.anyObject;
    OpenContainer *openCont = toc.openContainer;
    if (openCont == nil) {
        return [NSString stringWithFormat:@"%@_%@_%@.%@", self.language.topContainer.title, self.name, self.language.lc, FileExtensionUFW];
    }
    else {
        return [NSString stringWithFormat:@"%@_%@.%@", self.name, self.language.lc, FileExtensionUFW];
    }
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

- (DownloadStatus)statusText {
    if ([self isAllTextDownloaded]) {
        if ([self isAllTextValid]) {
            return DownloadStatusAllValid | DownloadStatusAll | DownloadStatusSome;
        } else {
            return DownloadStatusAll | DownloadStatusSome;
        }
    }
    else if ([self isAnyTextDownloaded]) {
        return DownloadStatusSome;
    }
    else {
        return DownloadStatusNone;
    }
}

- (BOOL)isAllTextValid
{
    for (UWTOC *toc in self.toc) {
        if (toc.isContentValidValue == NO) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)isAllTextDownloaded
{
    for (UWTOC *toc in self.toc) {
        if (toc.isDownloadedValue == NO) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)isAnyTextDownloaded
{
    for (UWTOC *toc in self.toc) {
        if (toc.isDownloadedValue == YES) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isAnyTextFailedDownload
{
    for (UWTOC *toc in self.toc) {
        if (toc.isDownloadFailedValue == YES) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Audio

- (DownloadStatus)statusAudio {
    if ([self hasAudio] == NO) {
        return DownloadStatusNoContent;
    }
    else if ([self allAudioDownloadedAndValid]) {
        return DownloadStatusAllValid | DownloadStatusAll | DownloadStatusSome;
    }
    else if ([self allAudioDownloaded]) {
        return DownloadStatusAll | DownloadStatusSome;
    }
    else if ([self anyAudioDownloaded]) {
        return DownloadStatusSome;
    }
    else {
        return DownloadStatusNone;
    }
}

// Check audio download status
- (BOOL)hasAudio {
    for (UWTOC *toc in self.toc) {
        if (toc.hasAudio) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)allAudioDownloaded
{
    if ([self hasAudio] == NO) {
        return NO;
    }
    for (UWTOC *toc in self.toc) {
        if (toc.allAudioDownloaded == NO) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)allAudioDownloadedAndValid
{
    if ([self hasAudio] == NO) {
        return NO;
    }
    for (UWTOC *toc in self.toc) {
        if (toc.allAudioDownloadedAndValid == NO) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)anyAudioDownloaded
{
    if ([self hasAudio] == NO) {
        return NO;
    }
    for (UWTOC *toc in self.toc) {
        if (toc.anyAudioDownloaded == YES) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Video

// Check video download status

- (DownloadStatus)statusVideo {
    if ([self hasVideo] == NO) {
        return DownloadStatusNoContent;
    }
    else if ([self allVideoDownloadedAndValid]) {
        return DownloadStatusAllValid | DownloadStatusAll | DownloadStatusSome;
    }
    else if ([self allVideoDownloaded]) {
        return DownloadStatusAll | DownloadStatusSome;
    }
    else if ([self anyVideoDownloaded]) {
        return DownloadStatusSome;
    }
    else {
        return DownloadStatusNone;
    }
}

- (BOOL)hasVideo {
    for (UWTOC *toc in self.toc) {
        if (toc.hasVideo) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)allVideoDownloaded {
    if ([self hasVideo] == NO) {
        return NO;
    }
    for (UWTOC *toc in self.toc) {
        if (toc.allVideoDownloaded == NO) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)allVideoDownloadedAndValid {
    if ([self hasVideo] == NO) {
        return NO;
    }
    for (UWTOC *toc in self.toc) {
        if (toc.allVideoDownloadedAndValid == NO) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)anyVideoDownloaded {
    if ([self hasVideo] == NO) {
        return NO;
    }
    for (UWTOC *toc in self.toc) {
        if (toc.anyVideoDownloaded == YES) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Downloading

- (void)downloadUsingOptions:(DownloadOptions)options completion:(VersionCompletion)completion;
{
    NSAssert1(options != DownloadOptionsEmpty, @"%s: Download options cannot be empty!", __PRETTY_FUNCTION__);

    if (self.toc.count == 0) {
        completion(NO, @"No items to download.");
    }
    else {
        [UWVersion addVersionDownloading:self options:options];
        [self downloadNextTOC:nil options:options completion:completion];
    }
}

- (void)downloadNextTOC:(UWTOC *)toc options:(DownloadOptions)options completion:(VersionCompletion)completion
{
    // If the TOC is already downloaded and valid, then skip to the next one
    UWTOC *nextTOC = [self nextTOC:toc];
    if ( [nextTOC isDownloadedForOptions:options]) {
        [self downloadNextTOC:nextTOC options:options completion:completion];
        return;
    }
    else if (nextTOC == nil) {
        [UWVersion removeVersionDownloading:self];
        completion(YES, nil);
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDownloadCompleteForVersion object:nil userInfo:@{kKeyVersionId:self.objectID.URIRepresentation.absoluteString}];
    }
    
    [nextTOC downloadUsingOptions:options completion:^(BOOL success) {
        if ([self nextTOC:nextTOC] != nil) {
            [self downloadNextTOC:nextTOC options:options completion:completion];
            if (success == NO) {
                [self.managedObjectContext deleteObject:nextTOC];
            }
            return;
        }
          if (success == NO) {
            [self.managedObjectContext deleteObject:nextTOC];
            [[DWSCoreDataStack managedObjectContext] save:nil];
        }
        if ([self isAllTextDownloaded]) {
            [[DWSCoreDataStack managedObjectContext] save:nil];
            [UWVersion removeVersionDownloading:self];
            completion(YES, nil);
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDownloadCompleteForVersion object:nil userInfo:@{kKeyVersionId:self.objectID.URIRepresentation.absoluteString}];
        }
        else {
            [[DWSCoreDataStack managedObjectContext] save:nil];
            [UWVersion removeVersionDownloading:self];
            completion(NO, @"Internal app error. Some items were not downloaded.");
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDownloadCompleteForVersion object:nil userInfo:@{kKeyVersionId:self.objectID.URIRepresentation.absoluteString}];
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

#pragma mark - Managing Version Download Info

- (DownloadOptions)currentDownloadingOptions {
    return [UWVersion downloadInfoForVersion:self];
}

+ (void)removeVersionDownloading:(UWVersion *)version
{
    [[self downloadDictionary] removeObjectForKey:version.objectID.URIRepresentation.absoluteString];
}

+ (void)addVersionDownloading:(UWVersion *)version options:(DownloadOptions)options
{
    [[self downloadDictionary] setObject:@(options) forKey:version.objectID.URIRepresentation.absoluteString];
}

+ (DownloadOptions)downloadInfoForVersion:(UWVersion *)version
{
    NSNumber *downloadOptionsNumber = [[self downloadDictionary] objectForKey:version.objectID.URIRepresentation.absoluteString];
    if (downloadOptionsNumber == nil) {
        return DownloadOptionsEmpty;
    } else {
        return downloadOptionsNumber.integerValue;
    }
}

+ (NSMutableDictionary *)downloadDictionary
{
    static NSMutableDictionary *_dictionaryDownloads = nil;
    if (_dictionaryDownloads == nil) {
        _dictionaryDownloads = [NSMutableDictionary new];
    }
    return _dictionaryDownloads;
}


@end
