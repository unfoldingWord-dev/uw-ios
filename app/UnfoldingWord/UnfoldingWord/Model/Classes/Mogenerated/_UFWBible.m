//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UFWBible.m instead.

#import "_UFWBible.h"

const struct UFWBibleAttributes UFWBibleAttributes = {
	.chapters_string = @"chapters_string",
	.current_chapter_number = @"current_chapter_number",
	.current_frame_number = @"current_frame_number",
	.languages_string = @"languages_string",
	.next_chapter_string = @"next_chapter_string",
};

const struct UFWBibleRelationships UFWBibleRelationships = {
	.chapters = @"chapters",
	.language = @"language",
};

const struct UFWBibleFetchedProperties UFWBibleFetchedProperties = {
};

@implementation UFWBibleID
@end

@implementation _UFWBible

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Bible" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Bible";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Bible" inManagedObjectContext:moc_];
}

- (UFWBibleID*)objectID {
	return (UFWBibleID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic chapters_string;

@dynamic current_chapter_number;

@dynamic current_frame_number;

@dynamic languages_string;

@dynamic next_chapter_string;

@dynamic chapters;

- (NSMutableSet*)chaptersSet {
	[self willAccessValueForKey:@"chapters"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"chapters"];

	[self didAccessValueForKey:@"chapters"];
	return result;
}

@dynamic language;

@end