//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OpenAppWordsList.m instead.

#import "_OpenAppWordsList.h"

const struct OpenAppWordsListAttributes OpenAppWordsListAttributes = {
	.cancel = @"cancel",
	.chapters = @"chapters",
	.languages = @"languages",
	.nextChapter = @"nextChapter",
	.ok = @"ok",
	.removeLocally = @"removeLocally",
	.removeThisLanguage = @"removeThisLanguage",
	.saveLocally = @"saveLocally",
	.saveThisLanguage = @"saveThisLanguage",
	.selectALanguage = @"selectALanguage",
	.slug = @"slug",
};

const struct OpenAppWordsListRelationships OpenAppWordsListRelationships = {
	.container = @"container",
};

const struct OpenAppWordsListFetchedProperties OpenAppWordsListFetchedProperties = {
};

@implementation _OpenAppWordsList

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"OpenAppWordsList" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"OpenAppWordsList";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"OpenAppWordsList" inManagedObjectContext:moc_];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic cancel;

@dynamic chapters;

@dynamic languages;

@dynamic nextChapter;

@dynamic ok;

@dynamic removeLocally;

@dynamic removeThisLanguage;

@dynamic saveLocally;

@dynamic saveThisLanguage;

@dynamic selectALanguage;

@dynamic slug;

@dynamic container;

@end