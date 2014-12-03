//
//  BiblicalDataModel.h
//  UnfoldingWord
//
//  Created by Acts Media Inc. on 28/11/14.
//  Copyright (c) 2014 Distant Shores Media All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface BiblicalDataModel : NSManagedObject

@property (nonatomic, retain) NSString * chapters_string;
@property (nonatomic, retain) NSString * language_code;
@property (nonatomic, retain) NSString * next_chapter;
@property (nonatomic, retain) NSData * chapters;
@property (nonatomic, retain) NSString * languages_title;

@end
