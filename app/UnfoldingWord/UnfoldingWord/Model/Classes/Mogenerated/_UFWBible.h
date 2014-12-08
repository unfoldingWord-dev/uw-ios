//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UFWBible.h instead.

#import <CoreData/CoreData.h>

extern const struct UFWBibleAttributes {
	__unsafe_unretained NSString *chapters_string;
	__unsafe_unretained NSString *current_chapter_number;
	__unsafe_unretained NSString *current_frame_number;
	__unsafe_unretained NSString *languages_string;
	__unsafe_unretained NSString *next_chapter_string;
} UFWBibleAttributes;

extern const struct UFWBibleRelationships {
	__unsafe_unretained NSString *chapters;
	__unsafe_unretained NSString *language;
} UFWBibleRelationships;

extern const struct UFWBibleFetchedProperties {
} UFWBibleFetchedProperties;

@class UFWChapter;
@class UFWLanguage;

@interface UFWBibleID : NSManagedObjectID {}
@end

@interface _UFWBible : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (UFWBibleID*)objectID;

@property (nonatomic, strong) NSString* chapters_string;

//- (BOOL)validateChapters_string:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* current_chapter_number;

//- (BOOL)validateCurrent_chapter_number:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* current_frame_number;

//- (BOOL)validateCurrent_frame_number:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* languages_string;

//- (BOOL)validateLanguages_string:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* next_chapter_string;

//- (BOOL)validateNext_chapter_string:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet* chapters;

- (NSMutableSet*)chaptersSet;

@property (nonatomic, strong) UFWLanguage* language;

//- (BOOL)validateLanguage:(id*)value_ error:(NSError**)error_;

@end

@interface _UFWBible (CoreDataGeneratedAccessors)

- (void)addChapters:(NSSet*)value_;
- (void)removeChapters:(NSSet*)value_;
- (void)addChaptersObject:(UFWChapter*)value_;
- (void)removeChaptersObject:(UFWChapter*)value_;

@end

@interface _UFWBible (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveChapters_string;
- (void)setPrimitiveChapters_string:(NSString*)value;

- (NSString*)primitiveCurrent_chapter_number;
- (void)setPrimitiveCurrent_chapter_number:(NSString*)value;

- (NSString*)primitiveCurrent_frame_number;
- (void)setPrimitiveCurrent_frame_number:(NSString*)value;

- (NSString*)primitiveLanguages_string;
- (void)setPrimitiveLanguages_string:(NSString*)value;

- (NSString*)primitiveNext_chapter_string;
- (void)setPrimitiveNext_chapter_string:(NSString*)value;

- (NSMutableSet*)primitiveChapters;
- (void)setPrimitiveChapters:(NSMutableSet*)value;

- (UFWLanguage*)primitiveLanguage;
- (void)setPrimitiveLanguage:(UFWLanguage*)value;

@end