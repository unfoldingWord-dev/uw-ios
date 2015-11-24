//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

#import "UWAudioBitrate.h"
#import "UWCoreDataClasses.h"
#import "NSString+Trim.h"
#import "UWDownloaderPlusValidator.h"
#import "Constants.h"
#import "UnfoldingWord-Swift.h"

static NSString *const kRate = @"bitrate";
static NSString *const kModified = @"mod";
static NSString *const kSize = @"size";


@implementation UWAudioBitrate

- (void)updateWithDictionary:(NSDictionary *)dictionary
{
    self.rate = [dictionary objectOrNilForKey:kRate];
    self.mod = [dictionary objectOrNilForKey:kModified];
    self.size = [dictionary objectOrNilForKey:kSize];
}

- (NSDictionary *)jsonRepresention
{
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    if (self.rate != nil) {
        dictionary[kRate] = self.rate;
    }
    if (self.mod != nil) {
        dictionary[kModified] = self.mod;
    }
    if (self.size != nil) {
        dictionary[kSize] = self.size;
    }
    return dictionary;
}

+ (void)updateBitrateDictionaries:(NSArray *)bitrateDictionaries forSource:(UWAudioSource *)source;
{
    NSArray *existingTOCItems = source.bitrates.allObjects;

    for (NSDictionary *bitrateDict in bitrateDictionaries) {
        UWAudioBitrate *theBitrate = [self objectForDictionary:bitrateDict withObjects:existingTOCItems];
        if (theBitrate == nil) {
            theBitrate = [UWAudioBitrate insertInManagedObjectContext:[DWSCoreDataStack managedObjectContext]];
        }
        [theBitrate updateWithDictionary:bitrateDict];
        theBitrate.source = source;
    }
}

- (BOOL)saveAudioAtPath:(NSString *)sourcePath withSignatureAtPath:(NSString *)sigPath isValid:(BOOL)isSignatureValid;
{
    // First save the audio data
    NSData *sourceData = sourcePath ? [NSData dataWithContentsOfFile:sourcePath] : nil;
    if (sourceData == nil) {
        return NO;
    }
    NSString *filename = self.filename ?: [FileNamer nameForAudioBitrate:self];
    NSString *sourcePermanentpath = [filename documentsPath];
    if ([sourceData writeToFile:sourcePermanentpath atomically:YES]) {
        self.filename = filename;
        self.isDownloadedValue = YES;
    }
    
    // Now deal with the signature
    NSData *sigData = sigPath ? [NSData dataWithContentsOfFile:sigPath] : nil;
    self.isValidValue = isSignatureValid;
    
    if (sigData) {
        self.signature = [UWDownloaderPlusValidator signatureFromServerRawData:sigData];
        NSString *sigFileName = [FileNamer nameForAudioSignatureBitrate:self];
        NSString *sigPermanentFilePath = [sigFileName documentsPath];
        [sigData writeToFile:sigPermanentFilePath atomically:YES];
    }
    
    if (sourcePath) {
        [[NSFileManager defaultManager] removeItemAtPath:sourcePath error:nil];
    }
    if (sigPath) {
        [[NSFileManager defaultManager] removeItemAtPath:sigPath error:nil];
    }
    
    return self.isDownloadedValue;
}

+ (instancetype)objectForDictionary:(NSDictionary *)dictionary withObjects:(NSArray *)existingObjects
{
    NSNumber *rate = [dictionary objectOrNilForKey:kRate];
    for (UWAudioBitrate *bitrate in existingObjects) {
        if ([bitrate.rate isEqualToNumber:rate]) {
            return bitrate;
        }
    }
    return nil;
}

@end
