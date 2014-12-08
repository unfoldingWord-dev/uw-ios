//
//  NSDictionary+DWSNull.h
//
//  Created by David Solberg on 4/5/13.
//  Copyright (c) 2013 David Solberg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (DWSNull)

/// Returns an object for the key or nil if the object is a pointer to NSNull. This protects against null values in converted JSON.
- (id)objectOrNilForKey:(id)aKey;

/// Returns a string or nil for the specified key. If the object is a NSNumber or anything else, it throws an exception (if enabled) and returns nil.
- (NSString *)validatedStringOrNilForKey:(id)aKey;

/// Returns a number or nil for the specified key. If the object is a NSString or anything else, it throws an exception (if enabled) and returns nil.
- (NSNumber *)validatedNumberOrNilForKey:(id)aKey;

@end
