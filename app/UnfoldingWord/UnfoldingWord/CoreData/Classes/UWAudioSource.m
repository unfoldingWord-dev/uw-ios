//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

#import "UWAudioSource.h"
#import "UWCoreDataClasses.h"

static NSString *const kBitrate = @"br";
static NSString *const kLength = @"length";
static NSString *const kModified = @"mod";
static NSString *const kSize = @"size";
static NSString *const kSource = @"src";
static NSString *const kSignature = @"src_sig";

@implementation UWAudioSource

- (void)updateWithDictionary:(NSDictionary *)dictionary
{
    if (dictionary.allKeys.count == 0) {
        NSAssert2(NO, @"%s: Dictionary contained no keys: %@", __PRETTY_FUNCTION__, dictionary);
        return;
    }
    NSString *key = [dictionary.allKeys firstObject];
    self.chapter = key;
    
    NSDictionary *enclosedDictionary = dictionary[key];
    
    self.bitrate = [enclosedDictionary objectOrNilForKey:kBitrate];
    self.length = [enclosedDictionary objectOrNilForKey:kLength];
    self.mod = [enclosedDictionary objectOrNilForKey:kModified];
    self.size = [enclosedDictionary objectOrNilForKey:kSize];
    self.src = [enclosedDictionary objectOrNilForKey:kSource];
    self.src_sig = [enclosedDictionary objectOrNilForKey:kSignature];
}

- (NSDictionary *)jsonRepresention
{
    NSMutableDictionary *innerDict = [NSMutableDictionary new];
    if (self.bitrate != nil) {
        innerDict[kBitrate] = self.bitrate;
    }
    if (self.length != nil) {
        innerDict[kLength] = self.length;
    }
    if (self.mod != nil) {
        innerDict[kModified] = self.mod;
    }
    if (self.size != nil) {
        innerDict[kSize] = self.size;
    }
    if (self.src != nil) {
        innerDict[kSource] = self.src;
    }
    if (self.src_sig != nil) {
        innerDict[kSignature] = self.src_sig;
    }
    
    // This is an odd way to do things, but it copies what the original JSON from uW looks like.
    NSMutableDictionary *outerDictionary = [NSMutableDictionary new];
    outerDictionary[self.chapter] = innerDict;
    
    return outerDictionary;
}

+ (instancetype)sourceForDictionary:(NSDictionary *)dictionary withExistingObjects:(NSArray *)existingObjects
{
    NSString *chapterIdentifier = (dictionary.allKeys.count > 0) ? dictionary.allKeys[0] : nil;
    if (chapterIdentifier == nil) {
        return nil;
    }
    
    for (UWAudioSource *existingSource in existingObjects) {
        if ([existingSource.chapter isEqualToString:chapterIdentifier]) {
            return existingSource;
        }
    }
    return nil;
}

@end
