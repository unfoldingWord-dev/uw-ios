//
//  NSString+Date.h
//  UnfoldingWord
//
//  Created by David Solberg on 2/16/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Date)

/// Returns a date object from the YYYYMMdd format (i.e. 20150131 for Jan 31, 2015)
- (NSDate*)dateYYYYMMdd;

/// Returns a string that tells the date in the current locale using a long style from the YYYYMMdd format (i.e. 20150131 for Jan 31, 2015)
- (NSString *)formattedDateFromYYYYMMdd;

@end
