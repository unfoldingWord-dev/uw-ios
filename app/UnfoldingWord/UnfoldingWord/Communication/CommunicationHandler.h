//
//  CommunicationHandler.h
//  UnfoldingWord
//
//  Created by Acts Media Inc. on 25/11/14.
//  Copyright (c) 2014 Distant Shores Media All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommunicationHandler : NSObject

+(void)callLanguageAPI;
+(void)callChapterAPI:(NSString*)getUrl With:(void (^)(NSDictionary *responseData, NSError *error))completionHandler;
@end
