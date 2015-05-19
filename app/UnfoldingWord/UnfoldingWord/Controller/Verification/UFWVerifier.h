//
//  UFWVerifier.h
//  UnfoldingWord
//
//  Created by David Solberg on 5/15/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UFWVerifier : NSObject

+ (BOOL)verifyFile:(NSString *)filePath withSignature:(NSString *)signature;

@end
