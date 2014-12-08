//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UFWFrame.m instead.

#import "_UFWFrame.h"

const struct UFWFrameAttributes UFWFrameAttributes = {
	.imageUrl = @"imageUrl",
	.text = @"text",
	.uid = @"uid",
};

const struct UFWFrameRelationships UFWFrameRelationships = {
	.chapter = @"chapter",
};

const struct UFWFrameFetchedProperties UFWFrameFetchedProperties = {
};

@implementation UFWFrameID
@end

@implementation _UFWFrame

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Frame" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Frame";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Frame" inManagedObjectContext:moc_];
}

- (UFWFrameID*)objectID {
	return (UFWFrameID*)[super objectID];
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