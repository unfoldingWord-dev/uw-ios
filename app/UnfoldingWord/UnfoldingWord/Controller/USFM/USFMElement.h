//
//  USFMElement.h
//  UnfoldingWord
//
//  Created by David Solberg on 4/27/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface USFMElement : NSObject

@property (nonatomic, strong, readonly) NSString *code;
@property (nonatomic, strong, readonly) NSString *text;
@property (nonatomic, strong, readonly) NSString *stringNumber;
@property (nonatomic, strong, readonly) NSNumber *numberMarker;

@property (nonatomic, readonly) BOOL isChapter;
@property (nonatomic, readonly) BOOL isVerse;
@property (nonatomic, readonly) BOOL isParagraph;
@property (nonatomic, readonly) BOOL isQuote;
@property (nonatomic, readonly) BOOL isLineBreak;

/// Elements are individual parsed objects from the raw USFM. It's readonly properties individuals what it does and how to format it.
+ (USFMElement *)newElementWithCodeInfo:(NSString *)codeInfo textInfo:(NSString *)textInfo;

/// Append additional text to the previous quote or verse. Returns YES if text was appended, or NO if the text could not be appended
- (BOOL)appendText:(NSString *)text;

@end
