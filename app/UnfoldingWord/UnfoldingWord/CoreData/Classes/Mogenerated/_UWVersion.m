//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UWVersion.m instead.

#import "_UWVersion.h"

const struct UWVersionAttributes UWVersionAttributes = {
	.mod = @"mod",
	.name = @"name",
	.slug = @"slug",
	.sortOrder = @"sortOrder",
};

const struct UWVersionRelationships UWVersionRelationships = {
	.language = @"language",
	.status = @"status",
	.toc = @"toc",
};

const struct UWVersionFetchedProperties UWVersionFetchedProperties = {
};

@implementation _UWVersion

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"UWVersion" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"UWVersion";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"UWVersion" inManagedObjectContext:moc_];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"sortOrderValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"sortOrder"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}

@dynamic mod;

@dynamic name;

@dynamic slug;

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

@dynamic language;

@dynamic status;

@dynamic toc;

- (NSMutableSet*)tocSet {
	[self willAccessValueForKey:@"toc"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"toc"];

	[self didAccessValueForKey:@"toc"];
	return result;
}

@end