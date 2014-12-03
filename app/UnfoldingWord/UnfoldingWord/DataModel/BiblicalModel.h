//
//  BiblicalModel.h
//  UnfoldingWord
//
//  Created by Acts Media Inc. on 28/11/14.
//  Copyright (c) 2014 Distant Shores Media All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BiblicalDataModel.h"

@interface BiblicalModel : NSObject

@property (nonatomic, retain) NSString * chapters_string;
@property (nonatomic, retain) NSString * language_code;
@property (nonatomic, retain) NSString * next_chapter;
@property (nonatomic, retain) NSArray *  chapters;
@property (nonatomic, retain) NSString * languages_title;
-(instancetype)initWithDict:(BiblicalDataModel*)dict ;

@end
