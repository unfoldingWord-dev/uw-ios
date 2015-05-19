//
//  LanguageInfoController.h
//  UnfoldingWord
//
//  Created by David Solberg on 5/7/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LanguageInfoController : NSObject

+ (NSTextAlignment)textAlignmentForLanguageCode:(NSString *)lc;

+ (NSString *)nameForLanguageCode:(NSString *)lc;

@end
