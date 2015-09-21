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
