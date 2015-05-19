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
+ (void)setUSFMTOC:(UWTOC *)toc;
+ (void)setJSONTOC:(UWTOC *)toc;
+ (void)setChapterUSFM:(NSInteger)chapter;
+ (void)setChapterJSON:(NSInteger)chapter;
+ (void)setFrameJSON:(NSInteger)frame;

+ (void)setTopContainer:(UWTopContainer *)topContainer;

+ (void)setUrlString:(NSString *)url;

// Getters
+ (UWTOC *)TOCforUSFM;
+ (UWTOC *)TOCforJSON;
+ (NSInteger)chapterNumberUSFM;
+ (NSInteger)chapterNumberJSON;
+ (NSInteger)frameNumberJSON;

+ (UWTopContainer *)topContainer;

+ (NSString *)urlString;

@end
