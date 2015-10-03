//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

#import "_UWAudioSource.h"
#import "Constants.h"

@interface UWAudioSource : _UWAudioSource {}

- (NSURL * __nullable)sourceFileUrl;

+ (instancetype __nullable)sourceForDictionary:(NSDictionary *__nonnull)dictionary withExistingObjects:(NSArray *__nonnull)existingObjects;

- (void)updateWithDictionary:(NSDictionary * __nonnull)dictionary;

- (NSDictionary * __nonnull)jsonRepresention;

- (void)downloadWithQuality:(AudioFileQuality)quality completion:(BitrateDownloadCompletion __nonnull)completion;

- (BOOL)hasPlayableContent;

- (UWAudioBitrate * __nullable)bestBitrateWithDownloadedAudio;

- (UWAudioBitrate * __nullable)bitrateWithQuality:(AudioFileQuality)quality;

@end
