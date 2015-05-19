//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

#import "UWStatus.h"
#import "UWCoreDataClasses.h"

static NSString *const kCheckEntity = @"checking_entity";
static NSString *const kCheckLevel = @"checking_level";
static NSString *const kComments = @"comments";
static NSString *const kContributors = @"contributors";
static NSString *const kPubDate = @"publish_date";
static NSString *const kSourcetext = @"source_text";
static NSString *const kSourceTextVer = @"source_text_version";
static NSString *const kVersion = @"version";

@interface UWStatus ()

@end

@implementation UWStatus

+ (void)updateStatus:(NSDictionary *)statusDic forVersion:(UWVersion *)version;
{
    UWStatus *status = nil;
    if (version.status == nil) {
        status = [UWStatus insertInManagedObjectContext:[DWSCoreDataStack managedObjectContext]];
    }
    [status updateWithDictionary:statusDic];
    status.uwversion = version;
}

- (void)updateWithDictionary:(NSDictionary *)dictionary
{
    self.checking_entity = [dictionary objectOrNilForKey:kCheckEntity];
    self.checking_level = [dictionary objectOrNilForKey:kCheckLevel];
    self.comments = [dictionary objectOrNilForKey:kComments];
    self.contributors = [dictionary objectOrNilForKey:kContributors];
    self.publish_date = [dictionary objectOrNilForKey:kPubDate];
    self.source_text = [dictionary objectOrNilForKey:kSourcetext];
    self.source_text_version = [dictionary objectOrNilForKey:kSourceTextVer];
    self.version = [dictionary objectOrNilForKey:kVersion];
}


@end
