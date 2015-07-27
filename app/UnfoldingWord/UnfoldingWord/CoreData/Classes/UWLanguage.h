//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

#import "_UWLanguage.h"
@class UWTopContainer;

@interface UWLanguage : _UWLanguage {}

@property (nonatomic, strong, readonly) NSArray *sortedVersions;

+ (void)updateLanguages:(NSArray *)languages forContainer:(UWTopContainer *)container;

- (NSDictionary *)jsonRepresentionWithoutVersions;


@end
