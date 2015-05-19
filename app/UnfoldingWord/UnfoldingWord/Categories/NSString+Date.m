//
//  NSString+Date.m
//  UnfoldingWord
//
//  Created by David Solberg on 2/16/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

#import "NSString+Date.h"

@implementation NSString (Date)

- (NSDate *)dateYYYYMMdd
{
    NSString *cleanedString = [self stringByReplacingOccurrencesOfString:@"-" withString:@""];
    static NSDateFormatter *__formatter = nil;
    if ( ! __formatter) {
        __formatter = [[NSDateFormatter alloc] init];
        [__formatter setDateFormat:@"YYYYMMdd"];
        [__formatter setTimeZone:[NSTimeZone systemTimeZone]];
    }
    NSDate *date = [__formatter dateFromString:cleanedString];
    return date;
}

- (NSString *)formattedDateFromYYYYMMdd
{
    NSDate *date = [self dateYYYYMMdd];
    if ( ! date) {
        return self;
    }
    static NSDateFormatter *__dateFormatter = nil;
    if ( ! __dateFormatter) {
        __dateFormatter = [[NSDateFormatter alloc] init];
        [__dateFormatter setDateStyle:NSDateFormatterLongStyle];
        [__dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        [__dateFormatter setLocale:[NSLocale currentLocale]];
    }
    return [__dateFormatter stringFromDate:date];
}

@end
