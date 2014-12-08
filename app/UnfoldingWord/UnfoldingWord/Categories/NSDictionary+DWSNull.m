//
//  NSDictionary+DWSNull.m
//
//  Created by David Solberg on 4/5/13.
//  Copyright (c) 2013 David Solberg. All rights reserved.
//

#import "NSDictionary+DWSNull.h"

@implementation NSDictionary (DWSNull)

- (NSString *)validatedStringOrNilForKey:(id)aKey
{
    if ([self validateObjectForKey:aKey isKindOfClass:[NSString class]]) {
        return [self objectOrNilForKey:aKey];
    }
    else {
        return nil;
    }
}

- (NSNumber *)validatedNumberOrNilForKey:(id)aKey
{
    if ([self validateObjectForKey:aKey isKindOfClass:[NSNumber class]]) {
        return [self objectOrNilForKey:aKey];
    }
    else {
        return nil;
    }
}

- (id)objectOrNilForKey:(id)aKey
{
    id object = [self objectForKey:aKey];
    
    // If we don't get an object, check for an initial uppercased string and for an initial lowercased string as well as all lowercase and all uppercase
    if ([aKey isKindOfClass:[NSString class]]) {
        if (! object) {
            object = [self objectForKey:[self stringByInitialCapitalizingString:aKey]];
        }
        if (! object) {
            object = [self objectForKey:[self stringByInitialLowercasingString:aKey]];
        }
        if (! object) {
            object = [self objectForKey:[aKey lowercaseString]];
        }
        if (! object) {
            object = [self objectForKey:[aKey uppercaseString]];
        }
    }
    
    if ([object isKindOfClass:[NSNull class]]) {
        return nil;
    }
    
    return object;
}

- (NSString *)stringByInitialCapitalizingString:(NSString *)originString
{
    if ([originString length] == 0) {
        return originString;
    }
    
    NSString *initialCapital = [originString substringWithRange:NSMakeRange(0, 1)];
    initialCapital = [initialCapital capitalizedString];
    if ([originString length] <= 1) {
        return initialCapital;
    }
    else {
        NSString *remainderString = [originString substringWithRange:NSMakeRange(1, [originString length]-1)];
        remainderString = [remainderString lowercaseString];
        return [initialCapital stringByAppendingString:remainderString];
    }
}

- (NSString *)stringByInitialLowercasingString:(NSString *)originString
{
    if ([originString length] == 0) {
        return originString;
    }
    
    NSString *initialLowercase = [originString substringWithRange:NSMakeRange(0, 1)];
    initialLowercase = [initialLowercase lowercaseString];
    if ([originString length] <= 1) {
        return initialLowercase;
    }
    else {
        NSString *remainderString = [originString substringWithRange:NSMakeRange(1, [originString length]-1)];
        return [initialLowercase stringByAppendingString:remainderString];
    }
}

- (BOOL)validateObjectForKey:(NSString *)key isKindOfClass:(Class)someClass
{
    id object = [self objectOrNilForKey:key];
    if (object == nil) {
        return YES;
    }
    else if ( ! [object isKindOfClass:someClass]) {
        NSString *errorString = [NSString stringWithFormat:@"The key \"%@\" returns \"%@\", but with should return an object of class %@", key, object, NSStringFromClass(someClass)];
        NSAssert1([object isKindOfClass:someClass], @"Validation Error: %@", errorString);
        return NO;
    }
    else {
        return YES;
    }
}

@end
