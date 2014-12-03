//
//  Utils.m
//  UnfoldingWord
//
//  Created by Acts Media Inc. on 26/11/14.
//  Copyright (c) 2014 Distant Shores Media All rights reserved.
//

#import "Utils.h"

@implementation Utils

+ (NSDate*)dateWithString:(NSString *)dateString withFormatterString:(NSString *)dateFormatterString timeZone:(NSTimeZone *)timeZone
{
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateFormatterString];
    if(timeZone)
        [dateFormatter setTimeZone:timeZone];
    else
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSDate *date = [dateFormatter dateFromString:dateString];
    return date;
}



@end
