//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UWTopContainer.m instead.

#import "_UWTopContainer.h"

const struct UWTopContainerAttributes UWTopContainerAttributes = {
	.slug = @"slug",
	.sortOrder = @"sortOrder",
	.title = @"title",
};

const struct UWTopContainerRelationships UWTopContainerRelationships = {
	.languages = @"languages",
};

const struct UWTopContainerFetchedProperties UWTopContainerFetchedProperties = {
};

@implementation _UWTopContainer

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"UWTopContainer" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"UWTopContainer";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"UWTopContainer" inManagedObjectContext:moc_];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"sortOrderValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"sortOrder"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}

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

@dynamic title;

@dynamic languages;

- (NSMutableSet*)languagesSet {
	[self willAccessValueForKey:@"languages"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"languages"];

	[self didAccessValueForKey:@"languages"];
	return result;
}

@end