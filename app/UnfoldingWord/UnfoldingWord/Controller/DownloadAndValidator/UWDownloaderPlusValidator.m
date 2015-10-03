//
//  UWDownloaderPlusValidator.m
//  UnfoldingWord
//
//  Created by David Solberg on 9/29/15.
//  Copyright © 2015 Acts Media Inc. All rights reserved.
//

#import "UWDownloaderPlusValidator.h"
#import "UWCoreDataClasses.h"
#import "NSString+Trim.h"
#import "UFWVerifier.h"

@implementation UWDownloaderPlusValidator

+ (void)downloadPlusValidateSourceUrl:(NSURL *)url signatureUrl:(NSURL *)sigUrl withCompletion:(UWDownloadValidatorCompletion)completion
{
    NSAssert4(url != nil && sigUrl != nil && completion != nil, @"%s: Failed to download url %@ with signature url %@ with completion %@", __PRETTY_FUNCTION__, url, sigUrl, completion);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:35];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *sourcePath = [self saveFileData:data];
            if (sourcePath == nil) {
                NSAssert2(sourcePath, @"%s: Could not get source path from data: %@", __PRETTY_FUNCTION__, data);
                completion(nil, nil, NO);
                return;
            }
            [self getSignaturefromUrl:sigUrl forSourceDataAtPath:sourcePath withCompletion:completion];
        });
    }];
    [task resume];
}

+ (void) getSignaturefromUrl:(NSURL *)url forSourceDataAtPath:(NSString *)sourceFilePath withCompletion: (UWDownloadValidatorCompletion) completion
{
    if (url == nil) {
        completion(sourceFilePath, nil, NO);
        return;
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:35];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        dispatch_async(dispatch_get_main_queue(), ^{
            
            // If we get a 404 error, then say the download failed, and delete it.
            if ([response isKindOfClass:[NSHTTPURLResponse class]] &&
                ((NSHTTPURLResponse *)response).statusCode == 404) {
#pragma mark - Fix - if we get a 404, we should delete the file.
//                [[NSFileManager defaultManager] removeItemAtPath:sourceFilePath error:nil];
                completion(sourceFilePath, nil, NO);
                return;
            }
            
            NSString *signaturePath = [self saveFileData:data];
            if (signaturePath == nil) {
                NSAssert2(signaturePath, @"%s: Could not get signature path from data: %@", __PRETTY_FUNCTION__, data);
                completion(sourceFilePath, nil, NO);
                return;
            }
            [self validateSourcePath:sourceFilePath usingSignaturePath:signaturePath withCompletion:completion];
        });
    }];
    [task resume];
}

+ (NSString *)saveFileData:(NSData *)data
{
    if ([data isKindOfClass:[NSData class]] == NO) {
        return nil;
    }
    
    NSArray *cacheDirectories = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *directory = [cacheDirectories objectAtIndex:0];
    NSString *path = [directory stringByAppendingPathComponent:[NSString uniqueString]];
    
    if ([data writeToFile:path atomically:YES]) {
        return path;
    }
    else {
        return nil;
    }
}

+ (BOOL)validateData:(NSData *)data withSignature:(NSString *)signature {
    NSString *temporaryFile = [self saveFileData:data];
    BOOL result = [UFWVerifier verifyFile:temporaryFile withSignature:signature];
    [[NSFileManager defaultManager] removeItemAtPath:temporaryFile error:nil];
    return result;
}

+ (void)validateSourcePath:(NSString *)sourcePath usingSignaturePath:(NSString *)signaturePath withCompletion:(UWDownloadValidatorCompletion)completion
{
    NSData *signatureData = [NSData dataWithContentsOfFile:signaturePath];
    NSString *signature = [self signatureFromServerRawData:signatureData];
    BOOL verified = [UFWVerifier verifyFile:sourcePath withSignature:signature];
    completion(sourcePath, signaturePath, verified);
}

+ (BOOL)validateSourcePath:(NSString *)sourcePath usingSignaturePath:(NSString *)signaturePath
{
    NSData *signatureData = [NSData dataWithContentsOfFile:signaturePath];
    NSString *signature = [self signatureFromServerRawData:signatureData];
    return [UFWVerifier verifyFile:sourcePath withSignature:signature];
}

+ (NSString *)signatureFromServerRawData:(NSData *)signatureData
{
    NSDictionary *signatureJSON = nil;
    if (signatureData.length > 0) {
        id responseObject = [NSJSONSerialization JSONObjectWithData:signatureData options:NSJSONReadingAllowFragments error:nil];
        if([responseObject isKindOfClass:[NSArray class]]) {
            NSArray *responseArray = (NSArray *)responseObject;
            if (responseArray.count > 0) {
                NSDictionary *baseDictionary = responseArray[0];
                if ([baseDictionary isKindOfClass:[NSDictionary class]]) {
                    signatureJSON = baseDictionary;
                }
            }
        }
    };
    return [signatureJSON objectOrNilForKey:@"sig"];
}

@end
