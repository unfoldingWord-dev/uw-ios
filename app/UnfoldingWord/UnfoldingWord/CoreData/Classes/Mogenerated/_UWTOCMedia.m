//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UWTOCMedia.m instead.

#import "_UWTOCMedia.h"

const struct UWTOCMediaAttributes UWTOCMediaAttributes = {
};

const struct UWTOCMediaRelationships UWTOCMediaRelationships = {
	.audio = @"audio",
	.toc = @"toc",
	.video = @"video",
};

const struct UWTOCMediaFetchedProperties UWTOCMediaFetchedProperties = {
};

@implementation _UWTOCMedia

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"UWTOCMedia" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"UWTOCMedia";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"UWTOCMedia" inManagedObjectContext:moc_];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic audio;

@dynamic toc;

@dynamic video;

@end