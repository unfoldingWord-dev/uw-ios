//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UFWChapter.h instead.

#import <CoreData/CoreData.h>

extern const struct UFWChapterAttributes {
	__unsafe_unretained NSString *number;
	__unsafe_unretained NSString *reference;
	__unsafe_unretained NSString *title;
} UFWChapterAttributes;

extern const struct UFWChapterRelationships {
	__unsafe_unretained NSString *bible;
	__unsafe_unretained NSString *frames;
} UFWChapterRelationships;

extern const struct UFWChapterFetchedProperties {
} UFWChapterFetchedProperties;

@class UFWBible;
@class UFWFrame;

@interface UFWChapterID : NSManagedObjectID {}
@end

@interface _UFWChapter : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (UFWChapterID*)objectID;

@property (nonatomic, strong) NSString* number;

//- (BOOL)validateNumber:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* reference;

//- (BOOL)validateReference:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* title;

//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) UFWBible* bible;

//- (BOOL)validateBible:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet* frames;

- (NSMutableSet*)framesSet;

@end

@interface _UFWChapter (CoreDataGeneratedAccessors)

- (void)addFrames:(NSSet*)value_;
- (void)removeFrames:(NSSet*)value_;
- (void)addFramesObject:(UFWFrame*)value_;
- (void)removeFramesObject:(UFWFrame*)value_;

@end

@interface _UFWChapter (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveNumber;
- (void)setPrimitiveNumber:(NSString*)value;

- (NSString*)primitiveReference;
- (void)setPrimitiveReference:(NSString*)value;

- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;

- (UFWBible*)primitiveBible;
- (void)setPrimitiveBible:(UFWBible*)value;

- (NSMutableSet*)primitiveFrames;
- (void)setPrimitiveFrames:(NSMutableSet*)value;

@end