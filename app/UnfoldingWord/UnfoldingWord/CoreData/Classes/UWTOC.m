//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

#import "UWTOC.h"
#import "UWCoreDataClasses.h"
#import "NSString+Trim.h"
#import "USFMCoding.h"
#import "Constants.h"
#import "UnfoldingWord-Swift.h"
#import "UWDownloaderPlusValidator.h"

static NSString *const kDescription = @"desc";
static NSString *const kModified = @"mod";
static NSString *const kSlug = @"slug";
static NSString *const kUrlSource = @"src";
static NSString *const kUrlSignature = @"src_sig";
static NSString *const kTitle = @"title";
static NSString *const kMedia = @"media";
static NSString *const kSortOrder = @"sort_order";

@implementation UWTOC
{
    NSString *_internalChapterTitle;
}

- (NSString *)chapterTitle
{
    if (_internalChapterTitle != nil) {
        return _internalChapterTitle;
    }
    
    NSString *title = self.usfmInfo.title;
    if (title == nil) {
        _internalChapterTitle = self.title;
    }
    else {
        _internalChapterTitle = title;
    }
    return _internalChapterTitle;
}

- (OpenChapter *)chapterForNumber:(NSInteger)number
{
    for (OpenChapter *chapter in self.openContainer.chapters) {
        if (chapter.number.integerValue == number) {
            return chapter;
        }
    };
    return nil;
}

+ (void)updateTOCitems:(NSArray *)tocItems forVersion:(UWVersion *)version;
{
    NSArray *existingTOCItems = version.toc.allObjects;
    
    int sort = 1;
    for (NSDictionary *tocDic in tocItems) {
        UWTOC *toc = [self objectForDictionary:tocDic withObjects:existingTOCItems];
        if (toc == nil) {
            toc = [UWTOC insertInManagedObjectContext:[DWSCoreDataStack managedObjectContext]];
        }
        toc.sortOrderValue = sort++;
        [toc updateWithDictionary:tocDic];
        toc.version = version;
    }
}

+ (instancetype)objectForDictionary:(NSDictionary *)dictionary withObjects:(NSArray *)existingObjects
{
    NSString *slug = [dictionary objectOrNilForKey:kSlug];
    for (UWTOC *toc in existingObjects) {
        if ([toc.slug isEqualToString:slug]) {
            return toc;
        }
    }
    return nil;
}

- (NSURL *)urlAudioForChapter:(NSInteger)chapter
{
    for (UWAudioSource *source in self.media.audio.sources) {
        if (source.chapter != nil && source.chapter.integerValue == chapter && source.src.length > 0) {
            return [NSURL URLWithString:source.src];
        }
    }
    return nil;
}

- (void)updateWithDictionary:(NSDictionary *)dictionary
{
    if (self.slug == nil) {
        self.isDownloaded = @(NO);
    }
    
    if ([self isServerMod:[dictionary objectOrNilForKey:kModified] isAfterLocalMod:self.mod]) {
        self.isContentChanged = @(YES);
    }
    
    self.uwDescription = [dictionary objectOrNilForKey:kDescription];
    self.mod = [dictionary objectOrNilForKey:kModified];
    self.slug = [dictionary objectOrNilForKey:kSlug];
    self.src = [dictionary objectOrNilForKey:kUrlSource];
    self.src_sig = [dictionary objectOrNilForKey:kUrlSignature];
    self.title = [dictionary objectOrNilForKey:kTitle];
    NSNumber *sortOrder = [dictionary objectOrNilForKey:kSortOrder];
    if (sortOrder) {
        self.sortOrder = sortOrder;
    }
    
    NSString *fileEnding = [self fileEndingForUrlPath:self.src];
    if ([fileEnding rangeOfString:@"usfm" options:NSCaseInsensitiveSearch].location == NSNotFound) {
        self.isUSFM = @(NO);
    }
    else {
        self.isUSFM = @(YES);
    }
    
    NSDictionary *mediaDict = [dictionary valueForKey:kMedia];
    if (mediaDict != nil && [mediaDict isKindOfClass:[NSDictionary class]]) {
        UWTOCMedia *media = self.media;
        if (media == nil) {
            media = [UWTOCMedia insertInManagedObjectContext:[DWSCoreDataStack managedObjectContext]];
            media.toc = self;       
        }
        [media updateWithDictionary:mediaDict];
    }
}

static NSString *const kFileEndingRegex = @"[.][a-z,A-Z,0-9]*\\z";
- (NSString *)fileEndingForUrlPath:(NSString *)path
{
    __block NSString *suffix = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:kFileEndingRegex options:NSRegularExpressionCaseInsensitive error:nil];
    [regex enumerateMatchesInString:path options:0 range:NSMakeRange(0, [path length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
        if (match.range.length > 0) {
            suffix = [path substringWithRange:match.range];
        }
    }];
    return suffix;
}

#pragma mark - Methods to import a file
- (BOOL)importWithUSFM:(NSString *)usfm signature:(NSString *)signature
{
    NSData *sourceData = [usfm dataUsingEncoding:NSUTF8StringEncoding];
    if ([self processUSFMString:usfm]) {
        [self setImportSuccessTrue];
        BOOL validated = [UWDownloaderPlusValidator validateData:sourceData withSignature:signature];
        self.isContentValidValue = validated;
        return validated;
    }
    else {
        return NO;
    }
}

- (BOOL)importWithOpenBible:(NSString *)openBible signature:(NSString *)signature
{
    NSData *openData = [openBible dataUsingEncoding:NSUTF8StringEncoding];
    if ([self processOpenBibleStoriesJSONData:openData]) {
        [self setImportSuccessTrue];
        return [UWDownloaderPlusValidator validateData:openData withSignature:signature];
    }
    else {
       return NO;
    }
}

- (BOOL)saveSignatureData:(NSData *)sigData withFilename:(NSString *)filename
{
    return [sigData writeToFile:[filename documentsPath] atomically:YES];
}


#pragma mark - Methods to Download the content for a TOC item.

- (BOOL)deleteContentForDownloadOptions:(DownloadOptions)options;

{
    if (self.isUSFM.boolValue) {
        return [self deleteUSFMContentForDownloadOptions:options];
    }
    else {
        return [self deleteJSONContentForDownloadOptions:options];
    }
}

- (BOOL)isDownloadedForOptions:(DownloadOptions)options
{
    NSAssert2(options != DownloadOptionsEmpty, @"%s: What ask if you're not downloading anything? %ld", __PRETTY_FUNCTION__, (long)options);
    
    if (options & DownloadOptionsText) {
        if (self.isContentChangedValue == YES || self.isDownloadedValue == NO) {
            return NO;
        }
    }
    if (options & DownloadOptionsAudio) {
        if ([self allAudioDownloaded] == NO) {
            return NO;
        }
    }
    if (options & DownloadOptionsVideo) {
        if ([self allVideoDownloaded] == NO) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)isDownloadedAndValidForOptions:(DownloadOptions)options
{
    NSAssert2(options != DownloadOptionsEmpty, @"%s: What ask if you're not downloading anything? %ld", __PRETTY_FUNCTION__, options);
    
    if (options & DownloadOptionsText) {
        if (self.isContentChangedValue == YES || self.isDownloadedValue == NO || self.isContentValidValue == NO) {
            return NO;
        }
    }
    if (options & DownloadOptionsAudio) {
        if ([self allAudioDownloadedAndValid] == NO) {
            return NO;
        }
    }
    if (options & DownloadOptionsVideo) {
        if ([self allVideoDownloadedAndValid] == NO) {
            return NO;
        }
    }
    return YES;
}

- (void)downloadUsingOptions:(DownloadOptions)options completion:(TOCDownloadCompletion)completion
{
    NSAssert2(options != DownloadOptionsEmpty, @"%s: No options for downloading: %@", __PRETTY_FUNCTION__, self);
    
    // Always download text when necessary
    if (self.isDownloadedValue == NO || self.isDownloadFailedValue == YES || self.isContentChangedValue == YES) {
        options = options | DownloadOptionsText;
    }
    
    if (options & DownloadOptionsText || self.isDownloadedValue == NO ) {
        [self startDownloadWithTextUsingOptions:options completion:completion];
    }
    else if (options & DownloadOptionsAudio) {
        [self startDownloadWithAudioUsingOptions:options completion:completion];
    }
    else if (options & DownloadOptionsVideo) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Video downloading not done yet." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil] show];
        completion(NO);
    }
    else {
        NSAssert2(NO, @"%s: Did not understand options: %ld", __PRETTY_FUNCTION__, options);
        completion(NO);
    }
}

- (void)startDownloadWithTextUsingOptions:(DownloadOptions)options completion:(TOCDownloadCompletion)completion {
    
    NSURL *sourceUrl = [NSURL URLWithString:self.src];
    NSURL *sigUrl = [NSURL URLWithString:self.src_sig];
    if ( ! sourceUrl || ! sigUrl) {
        NSAssert3(NO, @"%s: Do not call for a usfm download without a valid url source (%@) and signature (%@)!", __PRETTY_FUNCTION__, self.src, self.src_sig);
        completion(NO);
        return;
    }
    __weak typeof(self) weakself = self; // technically not needed, but following the pattern anyway.
    
    [UWDownloaderPlusValidator downloadPlusValidateSourceUrl:sourceUrl signatureUrl:sigUrl withCompletion:^(NSString * _Nullable sourceDataPath, NSString * _Nullable signatureDataPath, BOOL fileValidated) {
        
        // Get source data
        NSData *sourceData = nil;
        if (sourceDataPath != nil) {
            sourceData = [NSData dataWithContentsOfFile:sourceDataPath];
        }
        if (sourceData == nil ) {
            weakself.isDownloadFailed = @(YES);
            completion(NO);
            return;
        }
        
        // Get signature data
        NSData *sigData = nil;
        NSString *signature = nil;
        if (signatureDataPath != nil) {
            sigData = [NSData dataWithContentsOfFile:signatureDataPath];
            signature = [UWDownloaderPlusValidator signatureFromServerRawData:sigData];
        }
        
        BOOL importSuccessful = NO;
        NSString *signatureFileName = nil;
        
        if (weakself.isUSFM.boolValue) {
            NSString *usfm = [[NSString alloc] initWithData:sourceData encoding:NSUTF8StringEncoding];
            importSuccessful = [weakself processUSFMString:usfm];
            weakself.usfmInfo.signature = signature;
            signatureFileName = [weakself.usfmInfo.filename stringByAppendingString:SignatureFileAppend];
        }
        else {
            importSuccessful = [weakself processOpenBibleStoriesJSONData:sourceData];
            weakself.openContainer.signature = signature;
            signatureFileName = [weakself.openContainer.filename stringByAppendingString:SignatureFileAppend];
        }
        
        if (importSuccessful) {
            [self setImportSuccessTrue];
            self.isContentValidValue = fileValidated;
        }
        
        if (signatureFileName != nil && sigData != nil) {
            NSString *filepath = [[NSString documentsDirectory] stringByAppendingPathComponent:signatureFileName];
            if ([sigData writeToFile:filepath atomically:YES] == NO) {
                NSAssert1(NO, @"Could not save file to %@", filepath);
            }
        }
        
        [[DWSCoreDataStack managedObjectContext] save:nil];
        
        // Next download the audio if successful
        if (importSuccessful) {
            [self startDownloadWithAudioUsingOptions:options completion:completion];
        }
        else {
            completion(NO);
        }
    }];

}



- (void)startDownloadWithAudioUsingOptions:(DownloadOptions)options completion:(TOCDownloadCompletion)completion
{
    if (self.media.audio != nil && options & DownloadOptionsAudio) { // make sure that we don't call a nil
        AudioFileQuality quality = (options & DownloadOptionsLowQuality) ? AudioFileQualityLow : AudioFileQualityHigh;
        [self.media.audio downloadAllAudioWithQuality:quality completion:^(BOOL success) {
            completion(YES);
        }];
    }
    else {
        completion(YES);
    }
}

- (void)setImportSuccessTrue
{
    self.isDownloaded = @(YES);
    self.isDownloadFailed = @(NO);
    self.isContentChanged = @(NO);
}


#pragma mark - Audio Download Info

- (BOOL)hasAudio
{
    return (self.media.audio.sources.count > 0) ? YES : NO;
}

- (BOOL)allAudioDownloaded
{
    if ([self hasAudio] == NO) {
        return NO;
    }
    
    for (UWAudioSource *source in self.media.audio.sources) {
        if ( [source bestBitrateWithDownloadedAudio] == nil) {
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
    
    for (UWAudioSource *source in self.media.audio.sources) {
        if ([source bestBitrateWithDownloadedAudio].isValidValue == NO) {
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
    
    for (UWAudioSource *source in self.media.audio.sources) {
        if ([source bestBitrateWithDownloadedAudio] != nil) {
            return YES;
        }
    }
    return NO;
}


#pragma mark - Video Download Info

- (BOOL)hasVideo
{
    return NO;
//    return (self.media.video.sources.count > 0) ? YES : NO;
}

- (BOOL)allVideoDownloaded
{
//    if ([self hasVideo] == NO) {
        return NO;
//    }
}

- (BOOL)allVideoDownloadedAndValid
{
//    if ([self hasVideo] == NO) {
        return NO;
//    }
}

- (BOOL)anyVideoDownloaded {
    return NO;
}

#pragma mark - USFM

- (BOOL)deleteUSFMContentForDownloadOptions:(DownloadOptions)options
{
    BOOL result = YES;
    if (options & DownloadOptionsAudio || options & DownloadOptionsText) {
        result = [self deleteAllAudio];
    }
    if (result == YES && (options & DownloadOptionsVideo || options & DownloadOptionsText) ) {
        result = [self deleteAllVideo];
    }
    if (result == YES && (options & DownloadOptionsText) ) {
        result = [self deleteUSFMTextContent];
    }
    return result;
}

- (BOOL)deleteUSFMTextContent
{
    if (self.usfmInfo.filename == nil) {
        return YES;
    }
    
    BOOL success = NO;
    NSString *filePath = [[NSString documentsDirectory] stringByAppendingPathComponent:self.usfmInfo.filename];
    if ([[NSFileManager defaultManager] removeItemAtPath:filePath error:nil]) {
        success = YES;
    }
    else if ([[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:nil] == NO) {
        success = YES;
    }
    
    if (success == YES) {
        self.isDownloaded = @(NO);
        self.isContentValid = @(NO);
        self.isDownloadFailed = @(NO);
        [[DWSCoreDataStack managedObjectContext] deleteObject:self.usfmInfo];
        [[DWSCoreDataStack managedObjectContext] save:nil];
    }
    return success;
}

- (BOOL) processUSFMString:(NSString *)usfm
{
    NSArray *chapters = [UFWImporterUSFMEncoding chaptersFromString:usfm languageCode:self.version.language.lc];
    if (chapters.count > 0) {
        NSString *filename = (self.usfmInfo.filename.length == 0) ? [self uniqueFilename] : self.usfmInfo.filename;
        NSString *filepath = [[NSString documentsDirectory] stringByAppendingPathComponent:filename];
        if ([usfm writeToFile:filepath atomically:YES encoding:NSUTF8StringEncoding error:nil]) {
            USFMInfo *usfmInfo = self.usfmInfo;
            if (usfmInfo == nil) {
                usfmInfo = [USFMInfo insertInManagedObjectContext:[DWSCoreDataStack managedObjectContext]];
            }
            usfmInfo.filename = filename;
            usfmInfo.numberOfChapters = @(chapters.count);
            usfmInfo.toc = self;
            return YES;
        }
        else {
            self.isDownloadFailed = @(YES);
            return NO;
        }
    }
    else {
        self.isDownloadFailed = @(YES);
        return NO;
    }
}

#pragma mark - Open Bible Stories JSON

- (BOOL)deleteJSONContentForDownloadOptions:(DownloadOptions)options
{
    BOOL result = YES;
    if (options & DownloadOptionsAudio) {
        result = [self deleteAllAudio];
    }
    if (result == YES && (options & DownloadOptionsVideo) ) {
        result = [self deleteAllVideo];
    }
    if (result == YES && (options & DownloadOptionsText) ) {
        result = [self deleteJSONTextContent];
    }
    return result;
}

- (BOOL)deleteJSONTextContent
{
    BOOL success = NO;
    NSString *filepath = [[NSString documentsDirectory] stringByAppendingPathComponent:self.openContainer.filename];
    if ([[NSFileManager defaultManager] removeItemAtPath:filepath error:nil]) {
        success = YES;
    }
    else if ([[NSFileManager defaultManager] fileExistsAtPath:filepath isDirectory:nil] == NO) {
        success = YES;
    }
    
    if (success == YES) {
        self.isDownloaded = @(NO);
        self.isContentValid = @(NO);
        self.isDownloadFailed = @(NO);
        [[DWSCoreDataStack managedObjectContext] deleteObject:self.openContainer];
        [[DWSCoreDataStack managedObjectContext] save:nil];
    }
    return success;
}

- (BOOL)processOpenBibleStoriesJSONData:(NSData *)data
{
    NSJSONSerialization *JSON = nil;
    NSDictionary *dictionary = nil;
    if (data.length > 0) {
        JSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if([JSON isKindOfClass:[NSDictionary class]]){
            dictionary = (NSDictionary *)JSON;
        }
    };
    
    if (dictionary.allKeys.count > 0) {
        NSString *filename = (self.openContainer.filename.length == 0) ? [self uniqueFilename] : self.openContainer.filename;
        NSString *filepath = [[NSString documentsDirectory] stringByAppendingPathComponent:filename];
        if ([data writeToFile:filepath atomically:YES]) {
            OpenContainer *container = [OpenContainer createOpenContainerFromDictionary:dictionary forTOC:self];
            container.filename = filename;
            return YES;
        }
    }
    
    self.isDownloadFailed = @(YES);
    return NO;
}

- (BOOL)deleteAllAudio
{
    if ([self hasAudio] == NO) {
        return YES;
    }
    
    for (UWAudioSource *source in self.media.audio.sources) {
        if ([source deleteAllContent] == NO) {
            return NO;
        }
    }
    return YES;
}

- (BOOL) deleteAllVideo
{
    return YES;
}

- (NSString *)uniqueFilename
{
    NSString *suffix = (self.isUSFM.boolValue) ? @"usfm" : @"json";
    return [NSString stringWithFormat:@"%@-%@-%@-%@.%@", self.slug, self.version.slug, self.version.language.lc, [NSString uniqueString], suffix];
}


- (NSDictionary *)jsonRepresention
{
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    
    dictionary[kDescription] = self.uwDescription;
    dictionary[kModified] = self.mod;
    dictionary[kSlug] = self.slug;
    dictionary[kUrlSource] = self.src;
    dictionary[kUrlSignature] = self.src_sig;
    dictionary[kTitle] = self.title;
    dictionary[kSortOrder] = self.sortOrder;
    if (self.media != nil) {
        dictionary[kMedia] = [self.media jsonRepresention];
    }
    return dictionary;
}


@end
