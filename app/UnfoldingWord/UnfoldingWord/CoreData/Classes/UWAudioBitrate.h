//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

#import "_UWAudioBitrate.h"

@interface UWAudioBitrate : _UWAudioBitrate {}

- (void)updateWithDictionary:(NSDictionary *)dictionary;

- (NSDictionary *)jsonRepresention;

+ (void)updateBitrateDictionaries:(NSArray *)bitrateDictionaries forSource:(UWAudioSource *)source;

- (BOOL)saveAudioAtPath:(NSString *)sourcePath withSignatureAtPath:(NSString *)sigPath isValid:(BOOL)isSignatureValid;

@end
