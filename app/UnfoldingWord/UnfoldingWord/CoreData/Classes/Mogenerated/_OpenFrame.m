//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OpenFrame.m instead.

#import "_OpenFrame.h"

const struct OpenFrameAttributes OpenFrameAttributes = {
	.imageUrl = @"imageUrl",
	.text = @"text",
	.uid = @"uid",
};

const struct OpenFrameRelationships OpenFrameRelationships = {
	.chapter = @"chapter",
};

const struct OpenFrameFetchedProperties OpenFrameFetchedProperties = {
};

@implementation _OpenFrame

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"OpenFrame" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"OpenFrame";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"OpenFrame" inManagedObjectContext:moc_];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic imageUrl;

@dynamic text;

@dynamic uid;

@dynamic chapter;

@end