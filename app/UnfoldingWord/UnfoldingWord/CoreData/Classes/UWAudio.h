//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

#import "_UWAudio.h"
#import "Constants.h"

@interface UWAudio : _UWAudio {}

- (void)downloadAllAudioWithQuality:(AudioFileQuality)quality completion:(BitrateDownloadCompletion)completion;

- (void)updateWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)jsonRepresention;

@end
