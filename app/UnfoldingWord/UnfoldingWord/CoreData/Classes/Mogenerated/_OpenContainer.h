//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OpenContainer.h instead.

#import <CoreData/CoreData.h>

extern const struct OpenContainerAttributes {
	__unsafe_unretained NSString *direction;
	__unsafe_unretained NSString *filename;
	__unsafe_unretained NSString *language;
	__unsafe_unretained NSString *modified;
	__unsafe_unretained NSString *signature;
} OpenContainerAttributes;

extern const struct OpenContainerRelationships {
	__unsafe_unretained NSString *appWordsList;
	__unsafe_unretained NSString *chapters;
	__unsafe_unretained NSString *toc;
} OpenContainerRelationships;

extern const struct OpenContainerFetchedProperties {
} OpenContainerFetchedProperties;

@class OpenAppWordsList;
@class OpenChapter;
@class UWTOC;

@interface _OpenContainer : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;

@property (nonatomic, strong) NSString* direction;

//- (BOOL)validateDirection:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* filename;

//- (BOOL)validateFilename:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* language;

//- (BOOL)validateLanguage:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* modified;

//- (BOOL)validateModified:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* signature;

//- (BOOL)validateSignature:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) OpenAppWordsList* appWordsList;

//- (BOOL)validateAppWordsList:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet* chapters;

- (NSMutableSet*)chaptersSet;

@property (nonatomic, strong) UWTOC* toc;

//- (BOOL)validateToc:(id*)value_ error:(NSError**)error_;

@end

@interface _OpenContainer (CoreDataGeneratedAccessors)

- (void)addChapters:(NSSet*)value_;
- (void)removeChapters:(NSSet*)value_;
- (void)addChaptersObject:(OpenChapter*)value_;
- (void)removeChaptersObject:(OpenChapter*)value_;

@end

@interface _OpenContainer (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveDirection;
- (void)setPrimitiveDirection:(NSString*)value;

- (NSString*)primitiveFilename;
- (void)setPrimitiveFilename:(NSString*)value;

- (NSString*)primitiveLanguage;
- (void)setPrimitiveLanguage:(NSString*)value;

- (NSString*)primitiveModified;
- (void)setPrimitiveModified:(NSString*)value;

- (NSString*)primitiveSignature;
- (void)setPrimitiveSignature:(NSString*)value;

- (OpenAppWordsList*)primitiveAppWordsList;
- (void)setPrimitiveAppWordsList:(OpenAppWordsList*)value;

- (NSMutableSet*)primitiveChapters;
- (void)setPrimitiveChapters:(NSMutableSet*)value;

- (UWTOC*)primitiveToc;
- (void)setPrimitiveToc:(UWTOC*)value;

@end