//
//  NSString+Date.h
//  UnfoldingWord
//
//  Created by David Solberg on 2/16/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Date)

- (NSDate*)dateYYYYMMdd;

- (NSString *)formattedDateFromYYYYMMdd;

@end
