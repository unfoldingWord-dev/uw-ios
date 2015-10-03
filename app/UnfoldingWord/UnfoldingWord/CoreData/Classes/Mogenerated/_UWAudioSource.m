//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UWAudioSource.m instead.

#import "_UWAudioSource.h"

const struct UWAudioSourceAttributes UWAudioSourceAttributes = {
	.chapter = @"chapter",
	.length = @"length",
	.src = @"src",
	.src_sig = @"src_sig",
};

const struct UWAudioSourceRelationships UWAudioSourceRelationships = {
	.audio = @"audio",
	.bitrates = @"bitrates",
};

const struct UWAudioSourceFetchedProperties UWAudioSourceFetchedProperties = {
};

@implementation _UWAudioSource

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"UWAudioSource" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"UWAudioSource";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"UWAudioSource" inManagedObjectContext:moc_];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"lengthValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"length"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}

@dynamic chapter;

@dynamic length;

- (int64_t)lengthValue {
	NSNumber *result = [self length];
	return [result longLongValue];
}

- (void)setLengthValue:(int64_t)value_ {
	[self setLength:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveLengthValue {
	NSNumber *result = [self primitiveLength];
	return [result longLongValue];
}

- (void)setPrimitiveLengthValue:(int64_t)value_ {
	[self setPrimitiveLength:[NSNumber numberWithLongLong:value_]];
}

@dynamic src;

@dynamic src_sig;

@dynamic audio;

@dynamic bitrates;

- (NSMutableSet*)bitratesSet {
	[self willAccessValueForKey:@"bitrates"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"bitrates"];

	[self didAccessValueForKey:@"bitrates"];
	return result;
}

@end