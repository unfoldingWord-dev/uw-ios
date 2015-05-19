//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UWTOC.m instead.

#import "_UWTOC.h"

const struct UWTOCAttributes UWTOCAttributes = {
	.isContentChanged = @"isContentChanged",
	.isContentValid = @"isContentValid",
	.isDownloadFailed = @"isDownloadFailed",
	.isDownloaded = @"isDownloaded",
	.isUSFM = @"isUSFM",
	.mod = @"mod",
	.slug = @"slug",
	.sortOrder = @"sortOrder",
	.src = @"src",
	.src_sig = @"src_sig",
	.title = @"title",
	.uwDescription = @"uwDescription",
};

const struct UWTOCRelationships UWTOCRelationships = {
	.openContainer = @"openContainer",
	.usfmInfo = @"usfmInfo",
	.version = @"version",
};

const struct UWTOCFetchedProperties UWTOCFetchedProperties = {
};

@implementation _UWTOC

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"UWTOC" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"UWTOC";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"UWTOC" inManagedObjectContext:moc_];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"isContentChangedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isContentChanged"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"isContentValidValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isContentValid"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"isDownloadFailedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isDownloadFailed"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"isDownloadedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isDownloaded"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"isUSFMValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isUSFM"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"sortOrderValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"sortOrder"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}

@dynamic isContentChanged;

- (BOOL)isContentChangedValue {
	NSNumber *result = [self isContentChanged];
	return [result boolValue];
}

- (void)setIsContentChangedValue:(BOOL)value_ {
	[self setIsContentChanged:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsContentChangedValue {
	NSNumber *result = [self primitiveIsContentChanged];
	return [result boolValue];
}

- (void)setPrimitiveIsContentChangedValue:(BOOL)value_ {
	[self setPrimitiveIsContentChanged:[NSNumber numberWithBool:value_]];
}

@dynamic isContentValid;

- (BOOL)isContentValidValue {
	NSNumber *result = [self isContentValid];
	return [result boolValue];
}

- (void)setIsContentValidValue:(BOOL)value_ {
	[self setIsContentValid:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsContentValidValue {
	NSNumber *result = [self primitiveIsContentValid];
	return [result boolValue];
}

- (void)setPrimitiveIsContentValidValue:(BOOL)value_ {
	[self setPrimitiveIsContentValid:[NSNumber numberWithBool:value_]];
}

@dynamic isDownloadFailed;

- (BOOL)isDownloadFailedValue {
	NSNumber *result = [self isDownloadFailed];
	return [result boolValue];
}

- (void)setIsDownloadFailedValue:(BOOL)value_ {
	[self setIsDownloadFailed:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsDownloadFailedValue {
	NSNumber *result = [self primitiveIsDownloadFailed];
	return [result boolValue];
}

- (void)setPrimitiveIsDownloadFailedValue:(BOOL)value_ {
	[self setPrimitiveIsDownloadFailed:[NSNumber numberWithBool:value_]];
}

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

@dynamic isUSFM;

- (BOOL)isUSFMValue {
	NSNumber *result = [self isUSFM];
	return [result boolValue];
}

- (void)setIsUSFMValue:(BOOL)value_ {
	[self setIsUSFM:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsUSFMValue {
	NSNumber *result = [self primitiveIsUSFM];
	return [result boolValue];
}

- (void)setPrimitiveIsUSFMValue:(BOOL)value_ {
	[self setPrimitiveIsUSFM:[NSNumber numberWithBool:value_]];
}

@dynamic mod;

@dynamic slug;

@dynamic sortOrder;

- (int32_t)sortOrderValue {
	NSNumber *result = [self sortOrder];
	return [result intValue];
}

- (void)setSortOrderValue:(int32_t)value_ {
	[self setSortOrder:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveSortOrderValue {
	NSNumber *result = [self primitiveSortOrder];
	return [result intValue];
}

- (void)setPrimitiveSortOrderValue:(int32_t)value_ {
	[self setPrimitiveSortOrder:[NSNumber numberWithInt:value_]];
}

@dynamic src;

@dynamic src_sig;

@dynamic title;

@dynamic uwDescription;

@dynamic openContainer;

@dynamic usfmInfo;

@dynamic version;

@end