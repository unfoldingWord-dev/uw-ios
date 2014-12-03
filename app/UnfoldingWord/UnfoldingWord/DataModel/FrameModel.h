//
//  FrameModel.h
//  UnfoldingWord
//
//  Created by Acts Media Inc. on 28/11/14.
//  Copyright (c) 2014 Distant Shores Media All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FrameModel : NSObject

@property (nonatomic, retain) NSString * frame_id;
@property (nonatomic, retain) NSString * frame_image;
@property (nonatomic, retain) NSString * frame_text;

-(instancetype)initWithFrameDict:(NSDictionary*)frame;

@end
