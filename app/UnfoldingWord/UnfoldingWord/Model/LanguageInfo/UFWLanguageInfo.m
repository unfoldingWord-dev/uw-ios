//
//  BaseClass.m
//
//  Created by David Solberg on 5/7/15
//  Copyright (c) 2015 Infinite Sky LLC. All rights reserved.
//

#import "UFWLanguageInfo.h"


NSString *const kBaseClassCc = @"cc";
NSString *const kBaseClassLc = @"lc";
NSString *const kBaseClassLn = @"ln";
NSString *const kBaseClassLr = @"lr";
NSString *const kBaseClassGw = @"gw";
NSString *const kBaseClassLd = @"ld";


@interface UFWLanguageInfo ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation UFWLanguageInfo

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict
{
    return [[self alloc] initWithDictionary:dict];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
//            self.cc = [self objectOrNilForKey:kBaseClassCc fromDictionary:dict];
            self.languageCode = [self objectOrNilForKey:kBaseClassLc fromDictionary:dict];
            self.name = [self objectOrNilForKey:kBaseClassLn fromDictionary:dict];
//            self.lr = [self objectOrNilForKey:kBaseClassLr fromDictionary:dict];
//            self.gw = [[self objectOrNilForKey:kBaseClassGw fromDictionary:dict] boolValue];
            self.directionReading = [self objectOrNilForKey:kBaseClassLd fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
//    NSMutableArray *tempArrayForCc = [NSMutableArray array];
//    for (NSObject *subArrayObject in self.cc) {
//        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
//            // This class is a model object
//            [tempArrayForCc addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
//        } else {
//            // Generic object
//            [tempArrayForCc addObject:subArrayObject];
//        }
//    }
//    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForCc] forKey:kBaseClassCc];
    [mutableDict setValue:self.languageCode forKey:kBaseClassLc];
    [mutableDict setValue:self.name forKey:kBaseClassLn];
//    [mutableDict setValue:self.lr forKey:kBaseClassLr];
//    [mutableDict setValue:[NSNumber numberWithBool:self.gw] forKey:kBaseClassGw];
    [mutableDict setValue:self.directionReading forKey:kBaseClassLd];

    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

- (NSString *)description 
{
    return [NSString stringWithFormat:@"%@", [self dictionaryRepresentation]];
}

#pragma mark - Helper Method
- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict
{
    id object = [dict objectForKey:aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
}


#pragma mark - NSCoding Methods

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];

//    self.cc = [aDecoder decodeObjectForKey:kBaseClassCc];
    self.languageCode = [aDecoder decodeObjectForKey:kBaseClassLc];
    self.name = [aDecoder decodeObjectForKey:kBaseClassLn];
//    self.lr = [aDecoder decodeObjectForKey:kBaseClassLr];
//    self.gw = [aDecoder decodeBoolForKey:kBaseClassGw];
    self.directionReading = [aDecoder decodeObjectForKey:kBaseClassLd];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

//    [aCoder encodeObject:_cc forKey:kBaseClassCc];
    [aCoder encodeObject:_languageCode forKey:kBaseClassLc];
    [aCoder encodeObject:_name forKey:kBaseClassLn];
//    [aCoder encodeObject:_lr forKey:kBaseClassLr];
//    [aCoder encodeBool:_gw forKey:kBaseClassGw];
    [aCoder encodeObject:_directionReading forKey:kBaseClassLd];
}

- (id)copyWithZone:(NSZone *)zone
{
    UFWLanguageInfo *copy = [[UFWLanguageInfo alloc] init];
    
    if (copy) {

//        copy.cc = [self.cc copyWithZone:zone];
        copy.languageCode = [self.languageCode copyWithZone:zone];
        copy.name = [self.name copyWithZone:zone];
//        copy.lr = [self.lr copyWithZone:zone];
//        copy.gw = self.gw;
        copy.directionReading = [self.directionReading copyWithZone:zone];
    }
    
    return copy;
}


@end
