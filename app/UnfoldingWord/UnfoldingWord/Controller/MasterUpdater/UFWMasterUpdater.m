//
//  CommunicationHandler.m
//  UnfoldingWord
//
//  Created by Acts Media Inc. on 25/11/14.
//  Copyright (c) 2014 Distant Shores Media All rights reserved.
//
#import <UIKit/UIKit.h>

#import "UFWMasterUpdater.h"
#import "Constants.h"
#import "UWCoreDataClasses.h"
#import "UFWModelImageSync.h"
#import "UFWNotifications.h"
#import "UFWSelectionTracker.h"

static NSString *const kKeyTopContainers = @"cat";

@implementation UFWMasterUpdater

+ (void)update
{
    [self callProjectAPI];
}

+(void)callProjectAPI
{
    NSURL *url = [NSURL URLWithString:[UFWSelectionTracker urlString]];
    
    // Create a request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:15];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSDictionary *dictionary = nil;
        
        // Get the JSON dictionary if it exists
        if (data.length && error == nil) {
            id responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if([responseObject isKindOfClass:[NSDictionary class]]){
                dictionary = (NSDictionary *)responseObject;
            }
        };
        
        // Everything else should be on the main queue
        dispatch_async(dispatch_get_main_queue(), ^{
            if ( dictionary == nil) {
                [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Could not refresh at this time.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss", nil) otherButtonTitles: nil] show];
                [self postNotificationDownloadDone];
            }
            else {
                NSArray *topContainers = [dictionary objectOrNilForKey:kKeyTopContainers];
                [UWTopContainer updateFromArray:topContainers];
                [[DWSCoreDataStack managedObjectContext]save:nil];
                [self redownloadChangedItems];
            }
        });
    }];
    
    // Always forget this. Need to actually start it up.
    [task resume];
}

+ (void)redownloadChangedItems
{
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:[UWTOC entityName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isContentChanged = %@", @(YES)];
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"isDownloaded = %@", @(YES)];
    NSPredicate *bothPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, predicate2]];
    fetch.predicate = bothPredicate;
    
    NSError *error = nil;
    NSArray *tocToUpdateArray = [[DWSCoreDataStack managedObjectContext] executeFetchRequest:fetch error:&error];
    NSAssert1(! error, @"Error fetching TOC: %@", error.userInfo);
    
    if (tocToUpdateArray.count == 0) {
        [self postNotificationDownloadDone];
    }
    else {
        UWTOC *toc = [tocToUpdateArray firstObject];
        [toc downloadWithCompletion:^(BOOL success) {
            if (success == NO) {
                NSString *errorInstruction = NSLocalizedString(@"Could not refresh at this time.", nil);
                NSString *errorTitle = NSLocalizedString(@"failed to download.", @"the title of the failed item will be inserted at the beginning.");
                NSString *message = [NSString stringWithFormat:@"%@ %@ %@", toc.title, errorTitle, errorInstruction];
                [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss", nil) otherButtonTitles: nil] show];
                [self postNotificationDownloadDone];
            }
            else {
                [self redownloadChangedItems];
            }
        }];
    }
}


+ (void)updateImages
{
    [UFWModelImageSync downloadAllNecessaryImages];
}

+ (void)postNotificationDownloadDone
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDownloadEnded object:nil];
}

@end
