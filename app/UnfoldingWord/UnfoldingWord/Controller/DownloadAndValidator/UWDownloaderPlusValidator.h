//
//  UWDownloaderPlusValidator.h
//  UnfoldingWord
//
//  Created by David Solberg on 9/29/15.
//  Copyright © 2015 Acts Media Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^UWDownloadValidatorCompletion) (NSString * __nullable sourceDataPath, NSString * __nullable signatureDataPath, BOOL fileValidated);

@interface UWDownloaderPlusValidator : NSObject

+ (void)downloadPlusValidateSourceUrl:(NSURL * __nonnull)url signatureUrl:(NSURL * __nullable)sigUrl withCompletion:(UWDownloadValidatorCompletion __nonnull)completion;

+ (BOOL)validateSourcePath:(NSString *__nonnull)sourcePath usingSignaturePath:(NSString *__nonnull)signaturePath;

+ (NSString * __nullable)signatureFromServerRawData:(NSData * __nullable)signatureData;

+ (BOOL)validateData:(NSData *__nonnull)data withSignature:(NSString *__nonnull)signature;

@end
