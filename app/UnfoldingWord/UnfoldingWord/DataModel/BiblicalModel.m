//
//  BiblicalModel.m
//  UnfoldingWord
//
//  Created by Acts Media Inc. on 28/11/14.
//  Copyright (c) 2014 Distant Shores Media All rights reserved.
//

#import "BiblicalModel.h"
#import "ChapterFrameModel.h"
#import "FrameModel.h"

@implementation BiblicalModel

@synthesize chapters_string;
@synthesize language_code;
@synthesize next_chapter;
@synthesize chapters;
@synthesize languages_title;

-(instancetype)initWithDict:(BiblicalDataModel*)dict 
{
    self = [super init];
    if (self)
    {
        
        self.chapters_string = dict.chapters_string;
        self.language_code = dict.language_code;
        self.next_chapter = dict.next_chapter;
        self.languages_title = dict.languages_title;
        NSArray *chaptersArray = [NSKeyedUnarchiver unarchiveObjectWithData:dict.chapters];
        
        NSMutableArray *chaptersModelArray = [[NSMutableArray alloc] initWithCapacity:[chaptersArray count]];
        
        for(NSDictionary *chapter in chaptersArray)
        {
            
            ChapterFrameModel *chpt = [[ChapterFrameModel alloc] initWithChapterDict:chapter];
//            ChapterFrameModel *chapterModel = [[ChapterFrameModel alloc] initWithChapterDict:chapter];
            [chaptersModelArray addObject:chpt];
        }
        
        self.chapters =[chaptersModelArray copy];
        
        
    }
    return self;
}

@end
