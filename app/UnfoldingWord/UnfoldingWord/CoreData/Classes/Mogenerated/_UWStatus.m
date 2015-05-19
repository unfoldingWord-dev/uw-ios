//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UWStatus.m instead.

#import "_UWStatus.h"

const struct UWStatusAttributes UWStatusAttributes = {
	.checking_entity = @"checking_entity",
	.checking_level = @"checking_level",
	.comments = @"comments",
	.contributors = @"contributors",
	.publish_date = @"publish_date",
	.source_text = @"source_text",
	.source_text_version = @"source_text_version",
	.version = @"version",
};

const struct UWStatusRelationships UWStatusRelationships = {
	.uwversion = @"uwversion",
};

const struct UWStatusFetchedProperties UWStatusFetchedProperties = {
};

@implementation _UWStatus

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"UWStatus" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"UWStatus";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"UWStatus" inManagedObjectContext:moc_];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic checking_entity;

@dynamic checking_level;

@dynamic comments;

@dynamic contributors;

@dynamic publish_date;

@dynamic source_text;

@dynamic source_text_version;

@dynamic version;

@dynamic uwversion;

@end