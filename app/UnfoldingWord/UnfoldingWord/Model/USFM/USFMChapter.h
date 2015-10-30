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


- (NSAttributedString *)attributedStringWithSize:(double)size;

/// Given an array of USFM elements, will divide the elements into chapters and return and array of USFMChapter objects in order. Used by the UFWImporterUSFMEncoding class to create chapters from a raw USFM string. The language code is used to determine proper text alignment.
+ (NSArray *)createChaptersFromElements:(NSArray *)elements languageCode:(NSString *)languageCode;

@end
