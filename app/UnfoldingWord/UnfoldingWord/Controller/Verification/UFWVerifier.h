//
//  UFWVerifier.h
//  UnfoldingWord
//
//  Created by David Solberg on 5/15/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UFWVerifier : NSObject

/// Uses the uW public key "uW_vk_2.pem" to verify a given saved file using a base64 encoded signature string.
+ (BOOL)verifyFile:(NSString *)filePath withSignature:(NSString *)signature;

@end
