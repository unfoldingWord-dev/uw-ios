//
//  CommunicationHandler.m
//  UnfoldingWord
//
//  Created by Acts Media Inc. on 25/11/14.
//  Copyright (c) 2014 Distant Shores Media All rights reserved.
//

#import "CommunicationHandler.h"
#import "AFNetworking.h"
#import "DataHandler.h"
#import "Constants.h"




@implementation CommunicationHandler

+(void)callLanguageAPI
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:LANGUAGES_API parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        if([(NSArray *)responseObject count])
        {
            [DataHandler handleLanguages:(NSArray *)responseObject];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        NSLog(@"Error: %@", error);
    }];
}

+(void)callChapterAPI:(NSString*)getUrl With:(void (^)(NSDictionary *responseData, NSError *error))completionHandler
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:getUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         completionHandler((NSDictionary *)responseObject,nil);
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         completionHandler(nil,error);
     }];
}

@end
