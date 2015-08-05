//
//  UFWImporterUSFMEncoding.h
//  UnfoldingWord
//
//  Created by David Solberg on 2/24/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UFWImporterUSFMEncoding : NSObject

/// Returns an array of USFMChapter objects from a raw usfm string from the server.
+ (NSArray *)chaptersFromString:(NSString *)usfmString;

@end
