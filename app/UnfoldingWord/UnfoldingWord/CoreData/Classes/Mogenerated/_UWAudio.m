//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UWAudio.m instead.

#import "_UWAudio.h"

const struct UWAudioAttributes UWAudioAttributes = {
	.contributors = @"contributors",
	.rev = @"rev",
	.txt_ver = @"txt_ver",
};

const struct UWAudioRelationships UWAudioRelationships = {
	.media = @"media",
	.sources = @"sources",
};

const struct UWAudioFetchedProperties UWAudioFetchedProperties = {
};

@implementation _UWAudio

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"UWAudio" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"UWAudio";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"UWAudio" inManagedObjectContext:moc_];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic contributors;

@dynamic rev;

@dynamic txt_ver;

@dynamic media;

@dynamic sources;

- (NSMutableSet*)sourcesSet {
	[self willAccessValueForKey:@"sources"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"sources"];

	[self didAccessValueForKey:@"sources"];
	return result;
}

@end