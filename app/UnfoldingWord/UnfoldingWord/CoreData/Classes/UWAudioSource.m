//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

#import "UWAudioSource.h"
#import "UWCoreDataClasses.h"
#import "UWDownloaderPlusValidator.h"
#import "NSString+Trim.h"
#import "UnfoldingWord-Swift.h"

static NSString *const kChapter = @"chap";
static NSString *const kBitrate = @"br";
static NSString *const kLength = @"length";
static NSString *const kSource = @"src";
static NSString *const kSignature = @"src_sig";

static NSString *const KPLaceHolderForBitrate = @"{bitrate}";

@implementation UWAudioSource

- (void)updateWithDictionary:(NSDictionary *)dictionary
{
    self.chapter = [dictionary objectOrNilForKey:kChapter];
    self.length = [dictionary objectOrNilForKey:kLength];
    self.src = [dictionary objectOrNilForKey:kSource];
    self.src_sig = [dictionary objectOrNilForKey:kSignature];
    
    NSArray *bitrates = [dictionary objectOrNilForKey:kBitrate];
    [UWAudioBitrate updateBitrateDictionaries:bitrates forSource:self];
}

- (NSDictionary *)jsonRepresention
{
    NSMutableDictionary *dictionary = [NSMutableDictionary new];

    if (self.chapter != nil) {
        dictionary[kChapter] = self.chapter;
    }
    if (self.length != nil) {
        dictionary[kLength] = self.length;
    }
    if (self.src != nil) {
        dictionary[kSource] = self.src;
    }
    if (self.src_sig != nil) {
        dictionary[kSignature] = self.src_sig;
    }
    
    NSMutableArray *bitrates = [NSMutableArray new];
    for (UWAudioBitrate *bitrate in self.bitrates) {
        [bitrates addObject:[bitrate jsonRepresention]];
    }
    dictionary[kBitrate] = bitrates;
    
    return dictionary;
}

+ (instancetype)sourceForDictionary:(NSDictionary *)dictionary withExistingObjects:(NSArray *)existingObjects
{
    NSString *chapterIdentifier = (dictionary.allKeys.count > 0) ? dictionary.allKeys[0] : nil;
    if (chapterIdentifier == nil) {
        return nil;
    }
    
    for (UWAudioSource *existingSource in existingObjects) {
        if ([existingSource.chapter isEqualToString:chapterIdentifier]) {
            return existingSource;
        }
    }
    return nil;
}

- (NSURL *)sourceFileUrl
{
    UWAudioBitrate *bitrate = [self bestBitrateWithDownloadedAudio];
    if (bitrate == nil) {
        return nil;
    }
    NSString *filepath = [NSString documentsPathWithFilename:bitrate.filename];
    if (filepath == nil) {
        return nil;
    }
    return [NSURL fileURLWithPath:filepath];
}

- (void)downloadWithQuality:(AudioFileQuality)quality completion:(BitrateDownloadCompletion)completion
{
    UWAudioBitrate *bitrate = [self bitrateWithQuality:quality];
    NSString *sourceString = [self stringBySubstitutingUrlString:self.src withBitrate:bitrate];
    NSString *sigString = [self stringBySubstitutingUrlString:self.src_sig withBitrate:bitrate];
    
    if (bitrate == nil || sourceString == nil || sigString == nil) {
        completion(NO);
        return;
    }
    
    NSURL *sourceUrl = [NSURL URLWithString:sourceString];
    NSURL *signatureUrl = [NSURL URLWithString:sigString];
    if (sourceUrl == nil || signatureUrl == nil) {
        completion(NO);
        return;
    }
    
    NSLog(@"Filename: %@", [FileNamer nameForAudioBitrate:bitrate]);
    
    [UWDownloaderPlusValidator downloadPlusValidateSourceUrl:sourceUrl signatureUrl:signatureUrl withCompletion:^(NSString * _Nullable sourceDataPath, NSString * _Nullable signatureDataPath, BOOL fileValidated) {
        if (sourceDataPath == nil) {
            completion(NO);
            return;
        }
        else {
            BOOL success = [bitrate saveAudioAtPath:sourceDataPath withSignatureAtPath:signatureDataPath isValid:fileValidated];
            completion(success);
        }
    }];
}

- (BOOL)hasPlayableContent
{
    for (UWAudioBitrate *bitrate in self.bitrates) {
        if (bitrate.filename != nil && bitrate.isDownloadedValue) {
            return YES;
        }
    }
    return NO;
}

- (UWAudioBitrate *)bitrateWithQuality:(AudioFileQuality)quality
{
    switch (quality) {
        case AudioFileQualityHigh:
            return [self bitrateWithHighestQuality];
            break;
        case AudioFileQualityLow:
            return [self bitrateWithLowestQuality];
    }
    return nil;
}

- (UWAudioBitrate *)bestBitrateWithDownloadedAudio
{
    UWAudioBitrate *high = [self bitrateWithQuality:AudioFileQualityHigh];
    if (high.isDownloadedValue && high.filename != nil) {
        return high;
    }
    
    UWAudioBitrate *low = [self bitrateWithQuality:AudioFileQualityLow];
    if (low.isDownloadedValue && low.filename) {
        return low;
    }
    return nil;
}

- (UWAudioBitrate *)bitrateWithLowestQuality
{
    UWAudioBitrate * lowest = nil;
    
    for (UWAudioBitrate *bitrate in self.bitrates) {
        if (lowest == nil || bitrate.rate < lowest.rate) {
            lowest = bitrate;
        }
    }
    return lowest;
}

- (UWAudioBitrate *)bitrateWithHighestQuality
{
    UWAudioBitrate * lowest = nil;
    
    for (UWAudioBitrate *bitrate in self.bitrates) {
        if (lowest == nil || bitrate.rate >  lowest.rate) {
            lowest = bitrate;
        }
    }
    return lowest;
}


- (NSString *)stringBySubstitutingUrlString:(NSString *)urlString withBitrate:(UWAudioBitrate *)bitrate
{
    if (urlString == nil || bitrate == nil) {
        return nil;
    }
    NSString *rateString = bitrate.rate.stringValue;
    return [urlString stringByReplacingOccurrencesOfString:KPLaceHolderForBitrate withString:rateString];
}



@end
