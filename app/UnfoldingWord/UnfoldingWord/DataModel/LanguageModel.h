//
//  LanguageModel.h
//  UnfoldingWord
//
//  Created by Acts Media Inc. on 28/11/14.
//  Copyright (c) 2014 Distant Shores Media All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LanguageListModel.h"

@interface LanguageModel : NSObject

@property (nonatomic, retain) NSString * checking_entity;
@property (nonatomic, retain) NSString * checking_level;
@property (nonatomic, retain) NSString * date_modified;
@property (nonatomic, retain) NSString * language;
@property (nonatomic, retain) NSString * language_string;
@property (nonatomic, retain) NSString * publish_date;
@property (nonatomic, retain) NSString * version;


-(instancetype)initWithLanguageModel:(LanguageListModel*)lModel;

@end
