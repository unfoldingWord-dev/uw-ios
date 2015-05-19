//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OpenContainer.m instead.

#import "_OpenContainer.h"

const struct OpenContainerAttributes OpenContainerAttributes = {
	.direction = @"direction",
	.filename = @"filename",
	.language = @"language",
	.modified = @"modified",
	.signature = @"signature",
};

const struct OpenContainerRelationships OpenContainerRelationships = {
	.appWordsList = @"appWordsList",
	.chapters = @"chapters",
	.toc = @"toc",
};

const struct OpenContainerFetchedProperties OpenContainerFetchedProperties = {
};

@implementation _OpenContainer

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"OpenContainer" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"OpenContainer";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"OpenContainer" inManagedObjectContext:moc_];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic direction;

@dynamic filename;

@dynamic language;

@dynamic modified;

@dynamic signature;

@dynamic appWordsList;

@dynamic chapters;

- (NSMutableSet*)chaptersSet {
	[self willAccessValueForKey:@"chapters"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"chapters"];

	[self didAccessValueForKey:@"chapters"];
	return result;
}

@dynamic toc;

@end