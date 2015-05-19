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

+ (USFMElement *)newElementWithCodeInfo:(NSString *)codeInfo textInfo:(NSString *)textInfo;

@end
