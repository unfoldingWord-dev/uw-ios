//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UWAudioSource.m instead.

#import "_UWAudioSource.h"

const struct UWAudioSourceAttributes UWAudioSourceAttributes = {
	.bitrate = @"bitrate",
	.chapter = @"chapter",
	.length = @"length",
	.modified = @"modified",
	.size = @"size",
	.src = @"src",
	.src_sig = @"src_sig",
};

const struct UWAudioSourceRelationships UWAudioSourceRelationships = {
	.audio = @"audio",
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

	if ([key isEqualToString:@"bitrateValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"bitrate"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"lengthValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"length"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"modifiedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"modified"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"sizeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"size"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}

@dynamic bitrate;

- (int64_t)bitrateValue {
	NSNumber *result = [self bitrate];
	return [result longLongValue];
}

- (void)setBitrateValue:(int64_t)value_ {
	[self setBitrate:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveBitrateValue {
	NSNumber *result = [self primitiveBitrate];
	return [result longLongValue];
}

- (void)setPrimitiveBitrateValue:(int64_t)value_ {
	[self setPrimitiveBitrate:[NSNumber numberWithLongLong:value_]];
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

@dynamic modified;

- (double)modifiedValue {
	NSNumber *result = [self modified];
	return [result doubleValue];
}

- (void)setModifiedValue:(double)value_ {
	[self setModified:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveModifiedValue {
	NSNumber *result = [self primitiveModified];
	return [result doubleValue];
}

- (void)setPrimitiveModifiedValue:(double)value_ {
	[self setPrimitiveModified:[NSNumber numberWithDouble:value_]];
}

@dynamic size;

- (int64_t)sizeValue {
	NSNumber *result = [self size];
	return [result longLongValue];
}

- (void)setSizeValue:(int64_t)value_ {
	[self setSize:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveSizeValue {
	NSNumber *result = [self primitiveSize];
	return [result longLongValue];
}

- (void)setPrimitiveSizeValue:(int64_t)value_ {
	[self setPrimitiveSize:[NSNumber numberWithLongLong:value_]];
}

@dynamic src;

@dynamic src_sig;

@dynamic audio;

@end