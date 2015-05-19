//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OpenChapter.h instead.

#import <CoreData/CoreData.h>

extern const struct OpenChapterAttributes {
	__unsafe_unretained NSString *number;
	__unsafe_unretained NSString *reference;
	__unsafe_unretained NSString *title;
} OpenChapterAttributes;

extern const struct OpenChapterRelationships {
	__unsafe_unretained NSString *container;
	__unsafe_unretained NSString *frames;
} OpenChapterRelationships;

extern const struct OpenChapterFetchedProperties {
} OpenChapterFetchedProperties;

@class OpenContainer;
@class OpenFrame;

@interface _OpenChapter : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;

@property (nonatomic, strong) NSString* number;

//- (BOOL)validateNumber:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* reference;

//- (BOOL)validateReference:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* title;

//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) OpenContainer* container;

//- (BOOL)validateContainer:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet* frames;

- (NSMutableSet*)framesSet;

@end

@interface _OpenChapter (CoreDataGeneratedAccessors)

- (void)addFrames:(NSSet*)value_;
- (void)removeFrames:(NSSet*)value_;
- (void)addFramesObject:(OpenFrame*)value_;
- (void)removeFramesObject:(OpenFrame*)value_;

@end

@interface _OpenChapter (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveNumber;
- (void)setPrimitiveNumber:(NSString*)value;

- (NSString*)primitiveReference;
- (void)setPrimitiveReference:(NSString*)value;

- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;

- (OpenContainer*)primitiveContainer;
- (void)setPrimitiveContainer:(OpenContainer*)value;

- (NSMutableSet*)primitiveFrames;
- (void)setPrimitiveFrames:(NSMutableSet*)value;

@end