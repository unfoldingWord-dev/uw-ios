//
//  FrameModel.m
//  UnfoldingWord
//
//  Created by Acts Media Inc. on 28/11/14.
//  Copyright (c) 2014 Distant Shores Media All rights reserved.
//

#import "FrameModel.h"

@implementation FrameModel


@synthesize  frame_id;
@synthesize  frame_image;
@synthesize  frame_text;


-(instancetype)initWithFrameDict:(NSDictionary*)frame
{
    self = [super init];
    if (self) {
        self.frame_id = [frame valueForKey:@"id"];
        NSString *imageUrl =[frame valueForKey:@"img"];
        
        // to replace  {{ /}} from url {{https://api.unfoldingword.org/obs/jpg/1/en/360px/obs-en-03-16.jpg}}
        imageUrl = [imageUrl stringByReplacingOccurrencesOfString:@"{" withString:@""];
        imageUrl = [imageUrl stringByReplacingOccurrencesOfString:@"}" withString:@""];
        self.frame_image = imageUrl;
        self.frame_text = [frame valueForKey:@"text"];

        
        
    }
    return self;
}


@end
