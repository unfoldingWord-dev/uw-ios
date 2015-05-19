//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

#import "_UWTopContainer.h"

@interface UWTopContainer : _UWTopContainer {}

@property (nonatomic, assign, readonly) BOOL isUSFM;
@property (nonatomic, strong, readonly) NSArray *sortedLanguages;

+ (void)updateFromArray:(NSArray *)array;

@end
