//
//  USFMChapter.h
//  UnfoldingWord
//
//  Created by David Solberg on 4/28/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface USFMChapter : NSObject

/// Returns the chapter number as a STRING.
@property (nonatomic, strong, readonly) NSString *chapterNumber;

/// Creates an attributed string of the chapter suitable for displaying in a textview.
@property (nonatomic, strong, readonly) NSAttributedString *attributedString;

/// Used by the UFWImporterUSFMEncoding class to create chapters from a raw USFM string.
+ (NSArray *)createChaptersFromElements:(NSArray *)elements;

@end
