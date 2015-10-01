//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UWVideoSource.m instead.

#import "_UWVideoSource.h"

const struct UWVideoSourceAttributes UWVideoSourceAttributes = {
	.filename = @"filename",
	.mod = @"mod",
	.src = @"src",
	.src_sig = @"src_sig",
};

const struct UWVideoSourceRelationships UWVideoSourceRelationships = {
	.video = @"video",
};

const struct UWVideoSourceFetchedProperties UWVideoSourceFetchedProperties = {
};

@implementation _UWVideoSource

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"UWVideoSource" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"UWVideoSource";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"UWVideoSource" inManagedObjectContext:moc_];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"modValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"mod"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}

@dynamic filename;

@dynamic mod;

- (double)modValue {
	NSNumber *result = [self mod];
	return [result doubleValue];
}

- (void)setModValue:(double)value_ {
	[self setMod:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveModValue {
	NSNumber *result = [self primitiveMod];
	return [result doubleValue];
}

- (void)setPrimitiveModValue:(double)value_ {
	[self setPrimitiveMod:[NSNumber numberWithDouble:value_]];
}

@dynamic src;

@dynamic src_sig;

@dynamic video;

@end