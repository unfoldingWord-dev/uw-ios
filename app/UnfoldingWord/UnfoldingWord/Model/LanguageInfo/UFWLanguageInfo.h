//
//  BaseClass.h
//
//  Created by David Solberg on 5/7/15
//  Copyright (c) 2015 Infinite Sky LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

/// There's a lot of commented code here because it mimics the actual source file. I'm leaving it in b/c I think they might want it added back at some point.

@interface UFWLanguageInfo : NSObject <NSCoding, NSCopying>

//@property (nonatomic, strong) NSArray *cc;
@property (nonatomic, strong) NSString *languageCode;
@property (nonatomic, strong) NSString *name;
//@property (nonatomic, strong) NSString *lr;
//@property (nonatomic, assign) BOOL gw;
@property (nonatomic, strong) NSString *directionReading;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
//- (instancetype)initWithDictionary:(NSDictionary *)dict;
//- (NSDictionary *)dictionaryRepresentation;

@end
