//
//  USFMChapter.h
//  UnfoldingWord
//
//  Created by David Solberg on 4/28/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface USFMChapter : NSObject

@property (nonatomic, strong, readonly) NSString *chapterNumber;
@property (nonatomic, strong, readonly) NSAttributedString *attributedString;

+ (NSArray *)createChaptersFromElements:(NSArray *)elements;

@end
