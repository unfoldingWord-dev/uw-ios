//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OpenChapter.m instead.

#import "_OpenChapter.h"

const struct OpenChapterAttributes OpenChapterAttributes = {
	.number = @"number",
	.reference = @"reference",
	.title = @"title",
};

const struct OpenChapterRelationships OpenChapterRelationships = {
	.container = @"container",
	.frames = @"frames",
};

const struct OpenChapterFetchedProperties OpenChapterFetchedProperties = {
};

@implementation _OpenChapter

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"OpenChapter" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"OpenChapter";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"OpenChapter" inManagedObjectContext:moc_];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic number;

@dynamic reference;

@dynamic title;

@dynamic container;

@dynamic frames;

- (NSMutableSet*)framesSet {
	[self willAccessValueForKey:@"frames"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"frames"];

	[self didAccessValueForKey:@"frames"];
	return result;
}

@end