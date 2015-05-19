//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to USFMInfo.m instead.

#import "_USFMInfo.h"

const struct USFMInfoAttributes USFMInfoAttributes = {
	.filename = @"filename",
	.numberOfChapters = @"numberOfChapters",
	.signature = @"signature",
};

const struct USFMInfoRelationships USFMInfoRelationships = {
	.toc = @"toc",
};

const struct USFMInfoFetchedProperties USFMInfoFetchedProperties = {
};

@implementation _USFMInfo

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"USFMInfo" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"USFMInfo";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"USFMInfo" inManagedObjectContext:moc_];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"numberOfChaptersValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"numberOfChapters"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}

@dynamic filename;

@dynamic numberOfChapters;

- (int32_t)numberOfChaptersValue {
	NSNumber *result = [self numberOfChapters];
	return [result intValue];
}

- (void)setNumberOfChaptersValue:(int32_t)value_ {
	[self setNumberOfChapters:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveNumberOfChaptersValue {
	NSNumber *result = [self primitiveNumberOfChapters];
	return [result intValue];
}

- (void)setPrimitiveNumberOfChaptersValue:(int32_t)value_ {
	[self setPrimitiveNumberOfChapters:[NSNumber numberWithInt:value_]];
}

@dynamic signature;

@dynamic toc;

@end