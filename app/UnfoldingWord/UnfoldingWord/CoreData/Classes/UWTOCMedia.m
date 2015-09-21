//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

#import "UWTOCMedia.h"
#import "UWCoreDataClasses.h"
#import "NSDictionary+DWSNull.h"

static NSString *const kAudio = @"audio";
static NSString *const kVideo = @"video";

@implementation UWTOCMedia

- (void)updateWithDictionary:(NSDictionary *)dictionary
{
    NSDictionary *audioDic = [dictionary objectOrNilForKey:kAudio];
    if (audioDic != nil) {
        UWAudio *audio = self.audio;
        if (audio == nil) {
            audio = [UWAudio insertInManagedObjectContext:[DWSCoreDataStack managedObjectContext]];
        }
        [audio updateWithDictionary:audioDic];
    }
    
    NSDictionary *videoDic = [dictionary objectOrNilForKey:kVideo];
    if (videoDic != nil) {
        UWVideo *video = self.video;
        if (video == nil) {
            video = [UWVideo insertInManagedObjectContext:[DWSCoreDataStack managedObjectContext]];
        }
        [video updateWithDictionary:videoDic];
    }
}

- (NSDictionary *)jsonRepresention
{
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    NSObject *audio = [self.audio jsonRepresention];
    NSObject *video = [self.video jsonRepresention];
    if (audio != nil) {
        dictionary[kAudio] = audio;
    }
    if (video != nil) {
        dictionary[kVideo] = video;
    }
    
    return dictionary;
}


@end
