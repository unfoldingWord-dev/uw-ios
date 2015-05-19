//
//  NSManagedObject+Convenience.h
//  UnfoldingWord
//
//  Created by David Solberg on 4/29/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (Convenience)

/// Returns all incidences of the calling managed object. Requires the class name to be the same as the entity name. Use only on the main thread.
+ (NSArray *)allObjects;

- (BOOL)isServerMod:(NSString *)serverString isAfterLocalMod:(NSString *)localString;

@end
