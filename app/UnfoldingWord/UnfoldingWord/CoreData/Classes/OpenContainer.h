//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

#import "_OpenContainer.h"

@interface OpenContainer : _OpenContainer {}

+ (instancetype)createOpenContainerFromDictionary:(NSDictionary *)dictionary forTOC:(UWTOC *)toc;

- (BOOL)validateSignature;

- (NSArray *)sortedChapters;

@end
