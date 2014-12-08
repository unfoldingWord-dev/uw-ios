//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UFWChapter.m instead.

#import "_UFWChapter.h"

const struct UFWChapterAttributes UFWChapterAttributes = {
	.number = @"number",
	.reference = @"reference",
	.title = @"title",
};

const struct UFWChapterRelationships UFWChapterRelationships = {
	.bible = @"bible",
	.frames = @"frames",
};

const struct UFWChapterFetchedProperties UFWChapterFetchedProperties = {
};

@implementation UFWChapterID
@end

@implementation _UFWChapter

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Chapter" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Chapter";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Chapter" inManagedObjectContext:moc_];
}

- (UFWChapterID*)objectID {
	return (UFWChapterID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic number;

@dynamic reference;

@dynamic title;

@dynamic bible;

@dynamic frames;

- (NSMutableSet*)framesSet {
	[self willAccessValueForKey:@"frames"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"frames"];

	[self didAccessValueForKey:@"frames"];
	return result;
}

@end