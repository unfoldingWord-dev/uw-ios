//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OpenAppWordsList.h instead.

#import <CoreData/CoreData.h>

extern const struct OpenAppWordsListAttributes {
	__unsafe_unretained NSString *cancel;
	__unsafe_unretained NSString *chapters;
	__unsafe_unretained NSString *languages;
	__unsafe_unretained NSString *nextChapter;
	__unsafe_unretained NSString *ok;
	__unsafe_unretained NSString *removeLocally;
	__unsafe_unretained NSString *removeThisLanguage;
	__unsafe_unretained NSString *saveLocally;
	__unsafe_unretained NSString *saveThisLanguage;
	__unsafe_unretained NSString *selectALanguage;
	__unsafe_unretained NSString *slug;
} OpenAppWordsListAttributes;

extern const struct OpenAppWordsListRelationships {
	__unsafe_unretained NSString *container;
} OpenAppWordsListRelationships;

extern const struct OpenAppWordsListFetchedProperties {
} OpenAppWordsListFetchedProperties;

@class OpenContainer;

@interface _OpenAppWordsList : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;

@property (nonatomic, strong) NSString* cancel;

//- (BOOL)validateCancel:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* chapters;

//- (BOOL)validateChapters:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* languages;

//- (BOOL)validateLanguages:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* nextChapter;

//- (BOOL)validateNextChapter:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* ok;

//- (BOOL)validateOk:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* removeLocally;

//- (BOOL)validateRemoveLocally:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* removeThisLanguage;

//- (BOOL)validateRemoveThisLanguage:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* saveLocally;

//- (BOOL)validateSaveLocally:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* saveThisLanguage;

//- (BOOL)validateSaveThisLanguage:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* selectALanguage;

//- (BOOL)validateSelectALanguage:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* slug;

//- (BOOL)validateSlug:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) OpenContainer* container;

//- (BOOL)validateContainer:(id*)value_ error:(NSError**)error_;

@end

@interface _OpenAppWordsList (CoreDataGeneratedAccessors)

@end

@interface _OpenAppWordsList (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveCancel;
- (void)setPrimitiveCancel:(NSString*)value;

- (NSString*)primitiveChapters;
- (void)setPrimitiveChapters:(NSString*)value;

- (NSString*)primitiveLanguages;
- (void)setPrimitiveLanguages:(NSString*)value;

- (NSString*)primitiveNextChapter;
- (void)setPrimitiveNextChapter:(NSString*)value;

- (NSString*)primitiveOk;
- (void)setPrimitiveOk:(NSString*)value;

- (NSString*)primitiveRemoveLocally;
- (void)setPrimitiveRemoveLocally:(NSString*)value;

- (NSString*)primitiveRemoveThisLanguage;
- (void)setPrimitiveRemoveThisLanguage:(NSString*)value;

- (NSString*)primitiveSaveLocally;
- (void)setPrimitiveSaveLocally:(NSString*)value;

- (NSString*)primitiveSaveThisLanguage;
- (void)setPrimitiveSaveThisLanguage:(NSString*)value;

- (NSString*)primitiveSelectALanguage;
- (void)setPrimitiveSelectALanguage:(NSString*)value;

- (NSString*)primitiveSlug;
- (void)setPrimitiveSlug:(NSString*)value;

- (OpenContainer*)primitiveContainer;
- (void)setPrimitiveContainer:(OpenContainer*)value;

@end