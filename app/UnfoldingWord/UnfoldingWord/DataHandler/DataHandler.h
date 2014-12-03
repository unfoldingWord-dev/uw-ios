//
//  DataHandler.h
//  UnfoldingWord
//
//  Created by Acts Media Inc. on 26/11/14.
//  Copyright (c) 2014 Distant Shores Media All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BiblicalModel.h"

@interface DataHandler : NSObject

+(NSArray*)getLanguageList;
+(void)handleLanguages:(NSArray *)languages;

+(BiblicalModel*)getChaptersList:(NSString*)languageCode;

@end
