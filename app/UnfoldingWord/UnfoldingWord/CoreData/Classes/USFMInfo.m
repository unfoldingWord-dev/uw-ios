//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

#import "USFMInfo.h"
#import "UWCoreDataClasses.h"
#import "USFMCoding.h"
#import "NSString+Trim.h"
#import "UFWVerifier.h"

@interface USFMInfo ()

@end

@implementation USFMInfo

- (BOOL)validateSignature;
{
    NSString *filePath = [[NSString documentsDirectory] stringByAppendingPathComponent:self.filename];
    return [UFWVerifier verifyFile:filePath withSignature:self.signature];
}

- (NSArray *)chapters
{
    NSString *usfmText = [self usfmString];
    if ((usfmText = [self usfmString]).length == 0) {
        return nil;
    }
    else { 
        return [UFWImporterUSFMEncoding chaptersFromString:usfmText languageCode:self.toc.version.language.lc];
    }
}

- (NSString *)title
{
    NSString *usfmText = [self usfmString];
    if ((usfmText = [self usfmString]).length == 0) {
        return nil;
    }
    else {
        return [UFWImporterUSFMEncoding chapterIndividualTitleFromString:usfmText];
    }
}

- (NSString *)usfmString
{
    NSString *filePath = [[NSString documentsDirectory] stringByAppendingPathComponent:self.filename];
    NSString *usfmString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    if (usfmString.length > 0) {
        return usfmString;
    }
    else {
        return nil;
    }
}

@end
