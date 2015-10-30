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
@property (nonatomic, strong, readonly) NSString * __nonnull chapterNumber;

/// Creates an attributed string of the chapter suitable for displaying in a textview.
@property (nonatomic, strong, readonly) NSAttributedString * __nonnull attributedString;


- (NSAttributedString * __nonnull)attributedStringWithSize:(double)size;

/// Given an array of USFM elements, will divide the elements into chapters and return and array of USFMChapter objects in order. Used by the UFWImporterUSFMEncoding class to create chapters from a raw USFM string. The language code is used to determine proper text alignment.
+ (NSArray * __nonnull)createChaptersFromElements:(NSArray * __nonnull)elements languageCode:(NSString * __nullable)languageCode;

+ (NSString * __nullable)chapterNameFromElements:(NSArray * __nullable)elements;

@end
