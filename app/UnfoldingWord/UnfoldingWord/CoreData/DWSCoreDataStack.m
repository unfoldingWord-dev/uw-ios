//
//  DWSCoreDataStack.m
//
//  Created by David Solberg on 3/4/13.
//  Copyright (c) 2013 David Solberg. All rights reserved.
//

#import "DWSCoreDataStack.h"
#import "NSString+Trim.h"

/**
 kCoreDataModelName: enter the name of the core data model that ends with xcdatamodeld. This is used to get the right data model. This name is also used as the save name for the sqlite database in the user's documents folder.
 */
static NSString *kCoreDataModelName = @"UnfoldingWord";

/**
 kSeedNameInBundle: enter the database seed file in the app bundle. This is used if the previous database is wiped out or on first app launch. Setting to nil is the same as not seeding: an empty database is created instead.
 */
static NSString *kSeedNameInBundle = nil; // @"UnfoldingWordSeed.sqlite";

// ================================================================================== //


@implementation DWSCoreDataStack

#pragma mark - Core Data stack

+ (void) setup
{
    static DWSCoreDataStack *_singletonStack = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _singletonStack = [[DWSCoreDataStack alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:_singletonStack selector:@selector(contextSavedChanges:) name:NSManagedObjectContextDidSaveNotification object:nil];
        
        [DWSCoreDataStack managedObjectContext];
    });
}

- (void) contextSavedChanges:(NSNotification *)notification
{
    // This will be called when the managed object context on any thread changes.
    // If it's our context (which is on the main thread/queue), then nothing to do because it's already updated
    NSManagedObjectContext *callingContext = notification.object;
    if ([callingContext isEqual:[DWSCoreDataStack managedObjectContext]]) {
        return;
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[DWSCoreDataStack managedObjectContext] mergeChangesFromContextDidSaveNotification:notification];
        });
    }
}

+ (NSManagedObjectContext *)managedObjectContext
{
    static dispatch_once_t onceContextToken;
    static NSManagedObjectContext *_managedObjectContext = nil;
    dispatch_once(&onceContextToken, ^{
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        NSMergePolicy *mergePolicy = [[NSMergePolicy alloc] initWithMergeType:NSMergeByPropertyStoreTrumpMergePolicyType];
        [_managedObjectContext setMergePolicy:mergePolicy];
        [_managedObjectContext setPersistentStoreCoordinator:[[self class] persistentStoreCoordinator]];
    });
    return _managedObjectContext;
}

+ (NSManagedObjectModel *)managedObjectModel
{
    static dispatch_once_t onceModelToken;
    static NSManagedObjectModel *_managedObjectModel = nil;
    dispatch_once(&onceModelToken, ^{
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:kCoreDataModelName withExtension:@"momd"];
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        
    });
    return _managedObjectModel;
}

+ (void) deleteDatabase
{
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtURL:[self storeUrl] error:&error];
    if (error) {
        NSLog(@"Could not delete database");
    }
    
    // We're not always using these, so don't show an error even if there is one.
    [[NSFileManager defaultManager] removeItemAtURL:[self writeAheadLoggingUrl] error:&error];
    [[NSFileManager defaultManager] removeItemAtURL:[self indexUrl] error:&error];
}

+ (NSURL *)storeUrl
{
    return [[self documentsDirectoryURL] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", kCoreDataModelName]];
}

+(NSURL *)writeAheadLoggingUrl
{
    return [[self documentsDirectoryURL]  URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite-wal", kCoreDataModelName]];
}

+(NSURL *)indexUrl
{
    return [[self documentsDirectoryURL]  URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite-shm", kCoreDataModelName]];
}

+ (NSURL *)documentsDirectoryURL
{
    return [NSURL fileURLWithPath:[NSString documentsDirectory]];
}

+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    static dispatch_once_t oncePersistentStoreToken;
    static NSPersistentStoreCoordinator *_persistentStoreCoordinator = nil;
    dispatch_once(&oncePersistentStoreToken, ^{
        NSURL *storeURL = [[self class] storeUrl];
        
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        
        // Check for a seed if we have a seed file and if we don't already have a database
        if (kSeedNameInBundle && ! [fileManager fileExistsAtPath:[storeURL path]]) {
            
            NSURL *seedDatabaseURL = [[NSBundle mainBundle] URLForResource:kSeedNameInBundle withExtension:nil];
            NSAssert1(seedDatabaseURL, @"No file found in bundle for full file name %@", kSeedNameInBundle);
            
            NSError *error = nil;
            [fileManager copyItemAtURL:seedDatabaseURL toURL:storeURL error:&error];
            NSAssert2( ! error, @"Could not copy seed file at url %@ with error", seedDatabaseURL, error);
        }
        NSError *error = nil;
        NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption: @YES,
                                  NSInferMappingModelAutomaticallyOption: @YES,
                                  NSFileProtectionKey:NSFileProtectionCompleteUntilFirstUserAuthentication
                                  , NSSQLitePragmasOption:@{@"journal_mode":@"DELETE"} };
// This removes the write ahead log.
        
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[[self class] managedObjectModel]];
        
        if ( ! [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
            
            // It probably couldn't migrate the database. Instead, we're going to just dump the old stuff and redownload it.
            _persistentStoreCoordinator = [[self class] persistentStoreCoordinatorByDeletingOldData];
        }

    });
    return _persistentStoreCoordinator;
}

+ (NSPersistentStoreCoordinator *)persistentStoreCoordinatorByDeletingOldData
{
    // First remove the old database
    [self deleteDatabase];
    
    // Now create a fresh coordinator that will start with an empty file path
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[[self class] managedObjectModel]];
    NSURL *storeURL = [[self class] storeUrl];
    NSError *error = nil;
    if ( ! [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSAssert1(persistentStoreCoordinator, @"Could not reinitialize the database with url %@", storeURL);
    }
    
    // We also need to dump the user records of the last download date so downloads starts from scratch.
//    [ACTObjectDownloadDateTracker resetTrackingDates];
    
    // Alert the user what happened.
//    NSString *message = NSLocalizedString(@"This app's internal data structure has changed. Your information is now redownloading in the new format.", nil);
//    [[[UIAlertView alloc] initWithTitle:@"App Change!" message:message delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDatabaseDeleted object:nil];
    
    return persistentStoreCoordinator;
}


@end
