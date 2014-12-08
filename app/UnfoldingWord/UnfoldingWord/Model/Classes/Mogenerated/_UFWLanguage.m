//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UFWLanguage.m instead.

#import "_UFWLanguage.h"

const struct UFWLanguageAttributes UFWLanguageAttributes = {
	.checking_entity = @"checking_entity",
	.checking_level = @"checking_level",
	.date_modified = @"date_modified",
	.direction = @"direction",
	.isSelected = @"isSelected",
	.language = @"language",
	.language_string = @"language_string",
	.publish_date = @"publish_date",
	.version = @"version",
};

const struct UFWLanguageRelationships UFWLanguageRelationships = {
	.bible = @"bible",
};

const struct UFWLanguageFetchedProperties UFWLanguageFetchedProperties = {
};

@implementation UFWLanguageID
@end

@implementation _UFWLanguage

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Language" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Language";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Language" inManagedObjectContext:moc_];
}

- (UFWLanguageID*)objectID {
	return (UFWLanguageID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"isSelectedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isSelected"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}

@dynamic checking_entity;

@dynamic checking_level;

@dynamic date_modified;

@dynamic direction;

@dynamic isSelected;

- (BOOL)isSelectedValue {
	NSNumber *result = [self isSelected];
	return [result boolValue];
}

- (void)setIsSelectedValue:(BOOL)value_ {
	[self setIsSelected:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsSelectedValue {
	NSNumber *result = [self primitiveIsSelected];
	return [result boolValue];
}

- (void)setPrimitiveIsSelectedValue:(BOOL)value_ {
	[self setPrimitiveIsSelected:[NSNumber numberWithBool:value_]];
}

@dynamic language;

@dynamic language_string;

@dynamic publish_date;

@dynamic version;

@dynamic bible;

@end