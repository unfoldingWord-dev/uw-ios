//
//  ModelHandler.h
//  UnfoldingWord
//
//  Created by Acts Media Inc. on 25/11/14.
//  Copyright (c) 2014 Distant Shores Media All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BiblicalModel.h"

@interface ModelHandler : NSObject


+(void)insertLanguages:(NSArray *)languages;
+(NSMutableArray *)fetchLanguages;


+(void)insertBiblicalData:(NSDictionary *)data LanguageCode:(NSString*)languageCode;
+(BiblicalModel *)fetchBiblicalDataOf:(NSString*)languageCode;

@end
