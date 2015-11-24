//
//  NSString+Trim.m
//  UnfoldingWord
//
//  Created by David Solberg on 4/27/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

#import "NSString+Trim.h"

@implementation NSString (Trim)


- (NSString *)trimSpacesBeforeAfter
{
    NSArray *pieces = [self componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    // There can be empty pieces in some cases.
    NSMutableArray *fullPieces = [NSMutableArray new];
    for (NSString *piece in pieces) {
        if (piece.length > 0) {
            [fullPieces addObject:piece];
        }
    }
    return [fullPieces componentsJoinedByString:@" "];
}

+ (NSString *)uniqueString
{
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    NSString *uuidStr = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    return uuidStr;
}

- (BOOL)writeFileToDocumentsDirectory:(NSString *)filename atomically:(BOOL)useAuxiliaryFile encoding:(NSStringEncoding)enc error:(NSError **)error
{
    NSString *path = [filename documentsPath];
    return [self writeToFile:path atomically:YES encoding:enc error:error];
}

+ (instancetype)stringWithContentsOfFileInDocumentsDirectory:(NSString *)filename encoding:(NSStringEncoding)enc error:(NSError **)error
{
    NSString *path = [filename documentsPath];
    return [NSString stringWithContentsOfFile:path encoding:enc error:error];
}

- (NSString *)documentsPath
{
    return [[NSString documentsDirectory] stringByAppendingPathComponent:self];
}


+ (NSString *)documentsDirectory
{
    NSString *libraryDir = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0];
    NSString *documentsDirectory = [libraryDir stringByAppendingPathComponent:@"Documents"];
    [[NSFileManager defaultManager] createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    return documentsDirectory;
}

+ (NSString *)cacheTempDirectory
{
    NSString *libraryDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    NSString *tempDirectory = [libraryDir stringByAppendingPathComponent:@"Temp"];
    [[NSFileManager defaultManager] createDirectoryAtPath:tempDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    return tempDirectory;
}

+ (NSString *)appDocumentsDirectory
{
   return  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
}

+ (NSString *)cachesDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
}


- (CGFloat)widthUsingFont:(UIFont *)font
{
    if ([self length] == 0 || [font isKindOfClass:[UIFont class]] == NO) {
        return 0.f;
    }
    
    NSDictionary *attributes = @{NSFontAttributeName:font};
    CGRect boundingTextRect = [self boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    return ceilf(boundingTextRect.size.width);
}

@end
