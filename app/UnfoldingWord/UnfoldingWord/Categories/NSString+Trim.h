//
//  NSString+Trim.h
//  UnfoldingWord
//
//  Created by David Solberg on 4/27/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (Trim)

- (NSString *)trimSpacesBeforeAfter;
+ (NSString *)uniqueString;
+ (NSString *)documentsDirectory;
+ (NSString *)cachesDirectory;

+ (NSString *)appDocumentsDirectory;

+ (NSString *)documentsPathWithFilename:(NSString *)filename;

//- (BOOL)writeFileToDocumentsDirectory:(NSString *)filename atomically:(BOOL)useAuxiliaryFile encoding:(NSStringEncoding)enc error:(NSError **)error;
//
//+ (instancetype)stringWithContentsOfFileInDocumentsDirectory:(NSString *)filename encoding:(NSStringEncoding)enc error:(NSError **)error;

- (CGFloat)widthUsingFont:(UIFont *)font;

@end
