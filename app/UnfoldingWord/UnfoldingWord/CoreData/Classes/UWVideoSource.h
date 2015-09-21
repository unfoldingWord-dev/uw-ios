//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

#import "_UWVideoSource.h"

@interface UWVideoSource : _UWVideoSource {}

- (void)updateWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)jsonRepresention;

@end
