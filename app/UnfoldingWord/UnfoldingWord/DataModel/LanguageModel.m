//
//  LanguageModel.m
//  UnfoldingWord
//
//  Created by Acts Media Inc. on 28/11/14.
//  Copyright (c) 2014 Distant Shores Media All rights reserved.
//

#import "LanguageModel.h"

@implementation LanguageModel

@synthesize  checking_entity;
@synthesize  checking_level;
@synthesize  date_modified;
@synthesize  language;
@synthesize  language_string;
@synthesize  publish_date;
@synthesize  version;


-(instancetype)initWithLanguageModel:(LanguageListModel*)lModel
{
    
    
    
    self = [super init];
    if (self) {
        self.checking_entity = lModel.checking_entity;
        
        self.checking_level = lModel.checking_level;
        self.date_modified = lModel.date_modified;
        self.language = lModel.language;
        self.language_string = lModel.language_string;
        self.publish_date = lModel.publish_date;
        self.version = lModel.version;
        
        
    }
    return self;
}

@end
