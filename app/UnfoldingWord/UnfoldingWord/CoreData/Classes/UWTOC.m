//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

#import "UWTOC.h"
#import "UWCoreDataClasses.h"
#import "NSString+Trim.h"
#import "USFMCoding.h"
#import "Constants.h"
#import "UnfoldingWord-Swift.h"

static NSString *const kDescription = @"desc";
static NSString *const kModified = @"mod";
static NSString *const kSlug = @"slug";
static NSString *const kUrlSource = @"src";
static NSString *const kUrlSignature = @"src_sig";
static NSString *const kTitle = @"title";
static NSString *const kMedia = @"media";

@implementation UWTOC

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
        [toc updateWithDictionary:tocDic];
        toc.version = version;
        toc.sortOrderValue = sort++;
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
    if ([self processUSFMString:usfm]) {
        NSData *sigData = [signature dataUsingEncoding:NSUTF8StringEncoding];
        return [self validateWithSignature:sigData];
    }
    else {
        return NO;
    }
}

- (BOOL)importWithOpenBible:(NSString *)openBible signature:(NSString *)signature
{
    NSData *openData = [openBible dataUsingEncoding:NSUTF8StringEncoding];
    if ([self processOpenBibleStoriesJSONData:openData]) {
        NSData *sigData = [signature dataUsingEncoding:NSUTF8StringEncoding];
        return [self validateWithSignature:sigData];
    }
    else {
       return NO;
    }
}

#pragma mark - Methods to Download the content for a TOC item.

- (void)downloadWithCompletion:(TOCDownloadCompletion)completion;
{
    if (self.isUSFM.boolValue) {
        [self downloadUSFMFormatWithCompletion:completion];
    }
    else {
        [self downloadJSONFormatWithCompletion:completion];
    }
}

- (BOOL)deleteAllContent
{
    if (self.isUSFM.boolValue) {
        return [self deleteUSFMContent];
    }
    else {
        return [self deleteJSONContent];
    }
}

- (BOOL)isDownloadedAndValid
{
    if (self.isDownloadedValue == YES && self.isContentValidValue == YES && self.isContentChangedValue == NO) {
        return YES;
    }
    else {
        return NO;
    }
}

#pragma mark - USFM

- (BOOL)deleteUSFMContent
{
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

- (void)downloadUSFMFormatWithCompletion:(TOCDownloadCompletion)completion
{
    NSURL *url = [NSURL URLWithString:self.src];
    if ( ! url) {
        NSAssert2(NO, @"%s: Do not call for a usfm download without a valid url source (%@)!", __PRETTY_FUNCTION__, self.src);
        completion(NO);
        return;
    }
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:35];
    self.isDownloadFailed = @(NO);
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSString *usfm = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self processUSFMString:usfm]) {
                [self validateWithcompletion:completion];
            }
            else {
                completion(NO);
            }
        });
    }];
    [task resume];
}

- (BOOL) processUSFMString:(NSString *)usfm
{
    NSArray *chapters = [UFWImporterUSFMEncoding chaptersFromString:usfm];
    if (chapters.count > 0) {
        NSString *filename = [self uniqueFilenameWithSuffix:@"usfm"];
        NSString *filepath = [[NSString documentsDirectory] stringByAppendingPathComponent:filename];
        if ([usfm writeToFile:filepath atomically:YES encoding:NSUTF8StringEncoding error:nil]) {
            USFMInfo *usfmInfo = self.usfmInfo;
            if (usfmInfo == nil) {
                usfmInfo = [USFMInfo insertInManagedObjectContext:[DWSCoreDataStack managedObjectContext]];
            }
            usfmInfo.filename = filename;
            usfmInfo.numberOfChapters = @(chapters.count);
            usfmInfo.toc = self;
            [self updateForDownloadSuccess];
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

- (NSString *)uniqueFilenameWithSuffix:(NSString *)suffix
{
    return [NSString stringWithFormat:@"%@-%@-%@-%@.%@", self.slug, self.version.slug, self.version.language.lc, [NSString uniqueString], suffix];
}

#pragma mark - Open Bible Stories JSON

- (BOOL)deleteJSONContent
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

- (void)downloadJSONFormatWithCompletion:(TOCDownloadCompletion)completion
{
    // Create a request
    NSURL *url = [NSURL URLWithString:self.src];
    if ( ! url) {
        NSAssert2(NO, @"%s: Do not call for a download with a valid url source (%@)!", __PRETTY_FUNCTION__, self.src);
        completion(NO);
        return;
    }
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:35];
    self.isDownloadFailed = @(NO);
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error == nil && [self processOpenBibleStoriesJSONData:data]) {
                    [self validateWithcompletion:completion];
                }
                else {
                    completion(NO);
                }
            });
        });
    }];
    [task resume];
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
        NSString *filename = [self uniqueFilenameWithSuffix:@"json"];
        NSString *filepath = [[NSString documentsDirectory] stringByAppendingPathComponent:filename];
        if ([data writeToFile:filepath atomically:YES]) {
            OpenContainer *container = [OpenContainer createOpenContainerFromDictionary:dictionary forTOC:self];
            container.filename = filename;
            [self updateForDownloadSuccess];
            return YES;
        }
    }
    
    self.isDownloadFailed = @(YES);
    return NO;
}

#pragma mark - Signatures

// The completion block is always YES because we have successfully downloaded the usfm.
- (void)validateWithcompletion:(TOCDownloadCompletion)completion
{
    // Create a request
    NSURL *url = [NSURL URLWithString:self.src_sig];
    if ( ! url) {
        NSAssert2(NO, @"%s: Do not call for a usfm download verification with a valid url source (%@)!", __PRETTY_FUNCTION__, self.src_sig);
        completion(YES);
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:35];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // If we get a 404 error, then say the download failed, which will delete it.
            if ([response isKindOfClass:[NSHTTPURLResponse class]] &&
                ((NSHTTPURLResponse *)response).statusCode == 404) {
                completion(NO);
                return;
            }
            
            BOOL success = [self validateWithSignature:data];
            completion(success);
        });
    }];
    [task resume];
}

- (BOOL)validateWithSignature:(NSData *)data
{
    NSDictionary *signatureJSON = nil;
    self.isContentValid = @(NO);
    
    // Get the JSON dictionary if it exists
    if (data.length > 0) {
        id responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if([responseObject isKindOfClass:[NSArray class]]) {
            NSArray *responseArray = (NSArray *)responseObject;
            if (responseArray.count > 0) {
                NSDictionary *baseDictionary = responseArray[0];
                if ([baseDictionary isKindOfClass:[NSDictionary class]]) {
                    signatureJSON = baseDictionary;
                }
            }
        }
    };
    
    self.isContentValid = @(NO);
    
    if (signatureJSON.allKeys.count > 0) {
        
        NSString *signature = [signatureJSON objectOrNilForKey:@"sig"];
        
        if ( ! signature || ! [signature isKindOfClass:[NSString class]] || signature.length == 0) {
            NSAssert2(NO, @"%s: invalidate signature: %@", __PRETTY_FUNCTION__, signature);
        }
        else {
            NSString *filename = nil;
            
            if (self.usfmInfo != nil) {
                self.usfmInfo.signature = signature;
                self.isContentValid = @([self.usfmInfo validateSignature]);
                filename = [self.usfmInfo.filename stringByAppendingString:SignatureFileAppend];
            }
            else if (self.openContainer != nil) {
                self.openContainer.signature = signature;
                self.isContentValid = @([self.openContainer validateSignature]);
                filename = [self.openContainer.filename stringByAppendingString:SignatureFileAppend];
            }
            
            if (filename.length > 0) {
                NSString *filepath = [[NSString documentsDirectory] stringByAppendingPathComponent:filename];
                if ([data writeToFile:filepath atomically:YES] == NO) {
                    NSAssert1(NO, @"Could not save file to %@", filepath);
                }
            }
        }
    }
    else {
        NSAssert2(NO, @"%s: Could not find a signature! %@", __PRETTY_FUNCTION__, data);
    }
    [[DWSCoreDataStack managedObjectContext] save:nil];
    return self.isContentValidValue;
}

- (void)updateForDownloadSuccess
{
    self.isDownloaded = @(YES);
    self.isContentValid = @(NO);
    self.isDownloadFailed = @(NO);
    self.isContentChanged = @(NO);
    [[DWSCoreDataStack managedObjectContext] save:nil];
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
    if (self.media != nil) {
        dictionary[kMedia] = [self.media jsonRepresention];
    }
    return dictionary;
}


@end
