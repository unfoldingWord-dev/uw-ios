//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

#import "_UWStatus.h"
@class UWVersion;
@interface UWStatus : _UWStatus {}

+ (void)updateStatus:(NSDictionary *)status forVersion:(UWVersion *)version;

- (NSDictionary *)jsonRepresention;

@end
