//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UWVideo.m instead.

#import "_UWVideo.h"

const struct UWVideoAttributes UWVideoAttributes = {
};

const struct UWVideoRelationships UWVideoRelationships = {
	.media = @"media",
	.sources = @"sources",
};

const struct UWVideoFetchedProperties UWVideoFetchedProperties = {
};

@implementation _UWVideo

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"UWVideo" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"UWVideo";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"UWVideo" inManagedObjectContext:moc_];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic media;

@dynamic sources;

- (NSMutableSet*)sourcesSet {
	[self willAccessValueForKey:@"sources"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"sources"];

	[self didAccessValueForKey:@"sources"];
	return result;
}

@end