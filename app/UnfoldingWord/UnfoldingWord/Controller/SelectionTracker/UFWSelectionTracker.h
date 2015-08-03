//
//  UFWSelectionTracker.h
//  UnfoldingWord
//
//  Created by David Solberg on 5/12/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UWTOC, UWTopContainer;

@interface UFWSelectionTracker : NSObject

// Always call on the main thread.

// Setters: automatically saves to disk.
+ (void)setUSFMTOC:(UWTOC * __nullable)toc;
+ (void)setUSFMTOCSide:(UWTOC * __nullable)toc;
+ (void)setChapterUSFM:(NSInteger)chapter;

+ (void)setJSONTOC:(UWTOC * __nullable)toc;
+ (void)setJSONTOCSide:(UWTOC * __nullable)toc;

+ (void)setChapterJSON:(NSInteger)chapter;
+ (void)setFrameJSON:(NSInteger)frame;

+ (void)setTopContainer:(UWTopContainer * __nullable)topContainer;

+ (void)setUrlString:(NSString * __nullable)url;

// Getters
+ (UWTOC * __nullable)TOCforUSFM;
+ (UWTOC * __nullable)TOCforUSFMSide;
+ (NSInteger)chapterNumberUSFM;

+ (UWTOC * __nullable)TOCforJSON;
+ (UWTOC * __nullable)TOCforJSONSide;
+ (NSInteger)chapterNumberJSON;
+ (NSInteger)frameNumberJSON;

+ (UWTopContainer * __nullable)topContainer;

+ (NSString * __nonnull)urlString;

@end
