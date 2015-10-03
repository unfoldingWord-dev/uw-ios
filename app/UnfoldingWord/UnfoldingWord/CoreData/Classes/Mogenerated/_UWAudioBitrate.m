//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UWAudioBitrate.m instead.

#import "_UWAudioBitrate.h"

const struct UWAudioBitrateAttributes UWAudioBitrateAttributes = {
	.filename = @"filename",
	.isDownloaded = @"isDownloaded",
	.isValid = @"isValid",
	.mod = @"mod",
	.rate = @"rate",
	.signature = @"signature",
	.size = @"size",
};

const struct UWAudioBitrateRelationships UWAudioBitrateRelationships = {
	.source = @"source",
};

const struct UWAudioBitrateFetchedProperties UWAudioBitrateFetchedProperties = {
};

@implementation _UWAudioBitrate

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"UWAudioBitrate" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"UWAudioBitrate";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"UWAudioBitrate" inManagedObjectContext:moc_];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"isDownloadedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isDownloaded"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"isValidValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isValid"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"modValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"mod"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"rateValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"rate"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"sizeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"size"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}

@dynamic filename;

@dynamic isDownloaded;

- (BOOL)isDownloadedValue {
	NSNumber *result = [self isDownloaded];
	return [result boolValue];
}

- (void)setIsDownloadedValue:(BOOL)value_ {
	[self setIsDownloaded:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsDownloadedValue {
	NSNumber *result = [self primitiveIsDownloaded];
	return [result boolValue];
}

- (void)setPrimitiveIsDownloadedValue:(BOOL)value_ {
	[self setPrimitiveIsDownloaded:[NSNumber numberWithBool:value_]];
}

@dynamic isValid;

- (BOOL)isValidValue {
	NSNumber *result = [self isValid];
	return [result boolValue];
}

- (void)setIsValidValue:(BOOL)value_ {
	[self setIsValid:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsValidValue {
	NSNumber *result = [self primitiveIsValid];
	return [result boolValue];
}

- (void)setPrimitiveIsValidValue:(BOOL)value_ {
	[self setPrimitiveIsValid:[NSNumber numberWithBool:value_]];
}

@dynamic mod;

- (int64_t)modValue {
	NSNumber *result = [self mod];
	return [result longLongValue];
}

- (void)setModValue:(int64_t)value_ {
	[self setMod:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveModValue {
	NSNumber *result = [self primitiveMod];
	return [result longLongValue];
}

- (void)setPrimitiveModValue:(int64_t)value_ {
	[self setPrimitiveMod:[NSNumber numberWithLongLong:value_]];
}

@dynamic rate;

- (int64_t)rateValue {
	NSNumber *result = [self rate];
	return [result longLongValue];
}

- (void)setRateValue:(int64_t)value_ {
	[self setRate:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveRateValue {
	NSNumber *result = [self primitiveRate];
	return [result longLongValue];
}

- (void)setPrimitiveRateValue:(int64_t)value_ {
	[self setPrimitiveRate:[NSNumber numberWithLongLong:value_]];
}

@dynamic signature;

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

@dynamic source;

@end