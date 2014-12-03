//
//  ChapterFrameModel.m
//  UnfoldingWord
//
//  Created by Acts Media Inc. on 28/11/14.
//  Copyright (c) 2014 Distant Shores Media All rights reserved.
//

#import "ChapterFrameModel.h"
#import "FrameModel.h"

@implementation ChapterFrameModel

@synthesize  chapter_title;
@synthesize  frames;
@synthesize  chapter_number;
@synthesize  chapter_reference;


-(instancetype)initWithChapterDict:(NSDictionary*)chapter
{
    self = [super init];
    if (self) {
        self.chapter_title = [chapter valueForKey:@"title"];
        self.chapter_reference = [chapter valueForKey:@"ref"];
        self.chapter_number = [[chapter valueForKey:@"number"] integerValue];

        
        
        NSArray *frameList = [chapter valueForKey:@"frames"];
        NSAssert([frameList count], @"No Frames in Chapeter");
        self.frames = [[NSMutableArray alloc] initWithCapacity:[frameList count]];
        
        for(NSDictionary *frameDict in frameList)
        {
            FrameModel *frame = [[FrameModel alloc] initWithFrameDict:frameDict];
            [self.frames addObject:frame];
        }

        
    }
    return self;
}


@end
