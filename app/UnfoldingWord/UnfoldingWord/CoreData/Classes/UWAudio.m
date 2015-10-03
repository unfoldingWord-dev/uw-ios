//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

#import "UWAudio.h"
#import "UWCoreDataClasses.h"

static NSString *const kContributorsAudio = @"contributors";
static NSString *const kRevAudio = @"rev";
static NSString *const kTextVersionAudio = @"txt_ver";
static NSString *const kSourcesAudio = @"src_list";

@implementation UWAudio

- (void)downloadAllAudioWithQuality:(AudioFileQuality)quality completion:(BitrateDownloadCompletion)completion
{
    UWAudioSource *source = [self nextAudioSource:nil];
    if (source) {
        [self downloadAudioSource:source withQuality:quality completion:completion];
    }
    else { // Nothing to download
        completion(YES);
    }
}

- (void)downloadAudioSource:(UWAudioSource *)audioSource withQuality:(AudioFileQuality)quality completion:(BitrateDownloadCompletion)completion
{
    [audioSource downloadWithQuality:quality completion:^(BOOL success) {
        if (success) {
            UWAudioSource *nextSource = [self nextAudioSource:audioSource];
            if (nextSource == nil) {
                completion(YES);
            }
            else {
                [self downloadAudioSource:nextSource withQuality:quality completion:completion];
            }
        }
        else {
            completion(NO);
        }
    }];
}

- (UWAudioSource *)nextAudioSource:(UWAudioSource *)audioSource
{
    NSArray *sources = [self sortedAudioSources];
    if ([sources containsObject:audioSource]) {
        BOOL found = NO;
        for (UWAudioSource *aSource in sources) {
            if (found) {
                return aSource;
            }
            if ([aSource isEqual:audioSource]) {
                found = YES;
            }
        }
        // We must be on the last TOC.
        return nil;
    }
    else if (sources.count > 0) {
        return sources[0];
    }
    else {
        return nil;
    }
}

- (NSArray *)sortedAudioSources
{
    NSArray *tocArray = self.sources.allObjects;
    return [tocArray sortedArrayUsingComparator:^NSComparisonResult(UWAudioSource *source1, UWAudioSource *source2) {
        return [source1.chapter compare:source2.chapter];
    }];
}

#pragma mark - Import Export

- (void)updateWithDictionary:(NSDictionary *)dictionary
{
    self.contributors = [dictionary objectOrNilForKey:kContributorsAudio];
    self.rev = [dictionary objectOrNilForKey:kRevAudio];
    self.txt_ver = [dictionary objectOrNilForKey:kTextVersionAudio];
    
    NSArray *sources = [dictionary objectOrNilForKey:kSourcesAudio];
    if (sources.count == 0) {
        return;
    }
    
    for (NSDictionary *sourceDict in sources) {
        UWAudioSource *source = [UWAudioSource sourceForDictionary:sourceDict withExistingObjects:self.sources.allObjects];
        if (source == nil) {
            source = [UWAudioSource insertInManagedObjectContext:[DWSCoreDataStack managedObjectContext]];
            source.audio = self;
        }
        [source updateWithDictionary:sourceDict];
        source.audio = self;
    }
}

- (NSDictionary *)jsonRepresention
{
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    if (self.contributors != nil) {
        dictionary[kContributorsAudio] = self.contributors;
    }
    if (self.rev != nil) {
        dictionary[kRevAudio] = self.rev;
    }
    if (self.txt_ver != nil) {
        dictionary[kTextVersionAudio] = self.txt_ver;
    }
    
    NSMutableArray *sources = [NSMutableArray new];
    for (UWAudioSource *source in self.sources) {
        [sources addObject:[source jsonRepresention]];
    }
    dictionary[kSourcesAudio] = sources;
    
    return dictionary;
}



@end
