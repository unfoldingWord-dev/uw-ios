//
//  DWSCoreDataStack.h
//
//  Created by David Solberg on 3/4/13.
//  Copyright (c) 2013 David Solberg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DWSCoreDataStack : NSObject

/*!
 @method + setup
 @abstract This creates the managed object context for the main thread and registers for notifications so that changes on background contexts are merged when appropriate. Must be run on the main thread.
 */
+ (void) setup;


/*!
 @method + (NSManagedObjectContext *)managedObjectContext
 @abstract If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 @return The NSManagedObjectContext for the main thread.
*/

+ (NSManagedObjectContext *)managedObjectContext;


/*!
 @method + (NSManagedObjectModel *)managedObjectModel;
 @abstract If the model doesn't already exist, it is created from the application's model.
 @return NSManagedObjectModel for the application.
 */
+ (NSManagedObjectModel *)managedObjectModel;


/**
 @method + (NSManagedObjectModel *)managedObjectModel;
 @return NSPersistentStoreCoordinator for the application. If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator;

/**
 @method + (void)deleteDatabase;
 @abstract Deletes the sqlite database along with the write-ahead logging and index files. This will cause a crash if the database is being used. It must be called before any other method is called on app launch.
 */
+ (void) deleteDatabase;

@end
