//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

#import "_USFMInfo.h"

@interface USFMInfo : _USFMInfo {}

@property (nonatomic, strong, readonly) NSString * __nullable title;

- (BOOL)validateSignature;

- (NSArray * __nullable)chapters;

@end
