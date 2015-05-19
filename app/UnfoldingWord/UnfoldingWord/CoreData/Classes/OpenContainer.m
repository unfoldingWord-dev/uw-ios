//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

#import "OpenContainer.h"
#import "UWCoreDataClasses.h"
#import "NSString+Trim.h"
#import "UFWVerifier.h"
static NSString *const kApp_Words = @"app_words";
static NSString *const kChapters = @"chapters";
static NSString *const kModified = @"date_modified";
static NSString *const kDirection = @"direction";
static NSString *const kLanguage = @"language";

@interface OpenContainer ()

@end

@implementation OpenContainer

+ (instancetype)createOpenContainerFromDictionary:(NSDictionary *)dictionary forTOC:(UWTOC *)toc
{
    OpenContainer *container = toc.openContainer;
    
    if (container == nil) {
        container = [OpenContainer insertInManagedObjectContext:[DWSCoreDataStack managedObjectContext]];
        container.toc = toc;
    }
    [container updateWithDictionary:dictionary];
    return container;
}

- (void)updateWithDictionary:(NSDictionary *)dictionary;
{
    self.modified = [dictionary objectOrNilForKey:kModified];
    self.language = [dictionary objectOrNilForKey:kLanguage];
    self.direction = [dictionary objectOrNilForKey:kDirection];
    
    NSArray *chapters = [dictionary objectOrNilForKey:kChapters];
    [OpenChapter createChaptersFromArray:chapters forOpenContainer:self];
    
    NSDictionary *appWords = [dictionary objectOrNilForKey:kApp_Words];
    [OpenAppWordsList createWithDictionary:appWords forOpenContainer:self];
}

- (BOOL)validateSignature;
{
    NSString *signature = self.signature;
    NSString *filePath = [[NSString documentsDirectory] stringByAppendingPathComponent:self.filename];
    return [UFWVerifier verifyFile:filePath withSignature:signature];
}

- (NSArray *)sortedChapters
{
    return [self.chapters.allObjects sortedArrayUsingComparator:^NSComparisonResult(OpenChapter *chap1, OpenChapter *chap2) {
        return [@(chap1.number.integerValue) compare:@(chap2.number.integerValue)];
    }];
}

@end
