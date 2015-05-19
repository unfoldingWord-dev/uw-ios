//
//  UFWImporterUSFMEncoding.h
//  UnfoldingWord
//
//  Created by David Solberg on 2/24/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UFWBible;

@interface UFWImporterUSFMEncoding : NSObject

+ (NSArray *)chaptersFromString:(NSString *)usfmString;

@end
