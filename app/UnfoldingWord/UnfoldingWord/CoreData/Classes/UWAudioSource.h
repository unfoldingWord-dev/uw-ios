//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

#import "_UWAudioSource.h"

@interface UWAudioSource : _UWAudioSource {}

- (void)updateWithDictionary:(NSDictionary *)dictionary;

- (NSDictionary *)jsonRepresention;

+ (instancetype)sourceForDictionary:(NSDictionary *)dictionary withExistingObjects:(NSArray *)existingObjects;

@end
