//
//  ChapterFrameModel.h
//  UnfoldingWord
//
//  Created by Acts Media Inc. on 28/11/14.
//  Copyright (c) 2014 Distant Shores Media All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChapterFrameModel : NSObject


@property (nonatomic, retain) NSString * chapter_title;
@property (nonatomic, retain) NSMutableArray  * frames;
@property (nonatomic, assign) NSInteger chapter_number;
@property (nonatomic, retain) NSString * chapter_reference;

-(instancetype)initWithChapterDict:(NSDictionary*)chapter;

@end
