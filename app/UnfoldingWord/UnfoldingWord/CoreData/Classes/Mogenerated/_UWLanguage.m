//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UWLanguage.m instead.

#import "_UWLanguage.h"

const struct UWLanguageAttributes UWLanguageAttributes = {
	.lc = @"lc",
	.mod = @"mod",
	.sortOrder = @"sortOrder",
};

const struct UWLanguageRelationships UWLanguageRelationships = {
	.topContainer = @"topContainer",
	.versions = @"versions",
};

const struct UWLanguageFetchedProperties UWLanguageFetchedProperties = {
};

@implementation _UWLanguage

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"UWLanguage" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"UWLanguage";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"UWLanguage" inManagedObjectContext:moc_];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"sortOrderValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"sortOrder"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}

@dynamic lc;

@dynamic mod;

@dynamic sortOrder;

- (int32_t)sortOrderValue {
	NSNumber *result = [self sortOrder];
	return [result intValue];
}

- (void)setSortOrderValue:(int32_t)value_ {
	[self setSortOrder:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveSortOrderValue {
	NSNumber *result = [self primitiveSortOrder];
	return [result intValue];
}

- (void)setPrimitiveSortOrderValue:(int32_t)value_ {
	[self setPrimitiveSortOrder:[NSNumber numberWithInt:value_]];
}

@dynamic topContainer;

@dynamic versions;

- (NSMutableSet*)versionsSet {
	[self willAccessValueForKey:@"versions"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"versions"];

	[self didAccessValueForKey:@"versions"];
	return result;
}

@end