//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

#import "OpenAppWordsList.h"
#import "UWCoreDataClasses.h"

@interface OpenAppWordsList ()

@end

@implementation OpenAppWordsList

+ (instancetype)createWithDictionary:(NSDictionary *)dictionary forOpenContainer:(OpenContainer *)container
{
    OpenAppWordsList *wordList = container.appWordsList;
    if ( ! wordList) {
        wordList = [OpenAppWordsList insertInManagedObjectContext:[DWSCoreDataStack managedObjectContext]];
        wordList.container = container;
    }
    [wordList updateWithDictionary:dictionary];
    return wordList;
}

- (void)updateWithDictionary:(NSDictionary *)dictionary
{
    self.cancel = [dictionary objectOrNilForKey:@"cancel"];
    self.chapters = [dictionary objectOrNilForKey:@"chapters"];
    self.languages = [dictionary objectOrNilForKey:@"languages"];
    self.nextChapter = [dictionary objectOrNilForKey:@"next_chapter"];
    self.ok = [dictionary objectOrNilForKey:@"ok"];
    self.removeLocally = [dictionary objectOrNilForKey:@"remove_locally"];
    self.removeThisLanguage = [dictionary objectOrNilForKey:@"remove_this_string"];
    self.saveLocally = [dictionary objectOrNilForKey:@"save_locally"];
    self.saveThisLanguage = [dictionary objectOrNilForKey:@"save_this_string"];
    self.selectALanguage = [dictionary objectOrNilForKey:@"select_a_language"];
}

@end
