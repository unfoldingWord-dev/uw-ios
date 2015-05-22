
//
//  UFWDataSeeder.m
//  UnfoldingWord
//
//  Created by David Solberg on 5/18/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

#import "UFWDataSeeder.h"
#import "NSString+Trim.h"
#import "DWSCoreDataStack.h"

static NSString *const kDefaultDidCopy = @"did_copy_files";

@implementation UFWDataSeeder

+ (BOOL)seedDataIfNecessary
{
    NSNumber *didPreload = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultDidCopy];
    if (didPreload.boolValue == YES) {
        return YES;
    }
    
    [DWSCoreDataStack deleteDatabase];
    
    NSString *rootPath = [[NSBundle mainBundle] resourcePath];
    NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:rootPath];
    NSString *documentsDirectory = [NSString documentsDirectory];
    NSString *file = nil;
    NSError *error = nil;
    BOOL success = YES;
    while ((file = [dirEnum nextObject])) {
        NSString *extension = [file pathExtension];
        error = nil;
        if ([extension isEqualToString:@"json"] || [extension isEqualToString:@"usfm"] || [file isEqualToString:@"selection_tracker_dictionary.plist"]) {
            [[NSFileManager defaultManager] copyItemAtPath:[rootPath stringByAppendingPathComponent:file]  toPath:[documentsDirectory stringByAppendingPathComponent:file] error:&error];
        }
        if (error != nil) {
            success = NO;
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:kDefaultDidCopy];
    return success;
}

@end
