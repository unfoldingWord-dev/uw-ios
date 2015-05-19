//
//  NSManagedObject+Convenience.m
//  UnfoldingWord
//
//  Created by David Solberg on 4/29/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

#import "NSManagedObject+Convenience.h"
#import "CoreDataClasses.h"
#import "DWSCoreDataStack.h"

@implementation NSManagedObject (Convenience)

+ (NSArray *)allObjects
{
    NSAssert1([NSThread isMainThread], @"%s: must be called on main thread!", __PRETTY_FUNCTION__);
    NSManagedObjectContext *managedObjectContext = [DWSCoreDataStack managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([self class])];
    
    // Execute the fetch.
    NSError *error;
    NSArray *fetchResults = [managedObjectContext executeFetchRequest:request error:&error];
    NSAssert2( ! error, @"%s: Error fetching languages: %@", __PRETTY_FUNCTION__, error);
    
    return fetchResults;
}

- (BOOL)isServerMod:(NSString *)serverString isAfterLocalMod:(NSString *)localString;
{
    if (serverString.integerValue > localString.integerValue) {
        return YES;
    }
    else {
        return NO;
    }
}

@end
