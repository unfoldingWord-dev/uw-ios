//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OpenFrame.h instead.

#import <CoreData/CoreData.h>

extern const struct OpenFrameAttributes {
	__unsafe_unretained NSString *imageUrl;
	__unsafe_unretained NSString *text;
	__unsafe_unretained NSString *uid;
} OpenFrameAttributes;

extern const struct OpenFrameRelationships {
	__unsafe_unretained NSString *chapter;
} OpenFrameRelationships;

extern const struct OpenFrameFetchedProperties {
} OpenFrameFetchedProperties;

@class OpenChapter;

@interface _OpenFrame : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;

@property (nonatomic, strong) NSString* imageUrl;

//- (BOOL)validateImageUrl:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* text;

//- (BOOL)validateText:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* uid;

//- (BOOL)validateUid:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) OpenChapter* chapter;

//- (BOOL)validateChapter:(id*)value_ error:(NSError**)error_;

@end

@interface _OpenFrame (CoreDataGeneratedAccessors)

@end

@interface _OpenFrame (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveImageUrl;
- (void)setPrimitiveImageUrl:(NSString*)value;

- (NSString*)primitiveText;
- (void)setPrimitiveText:(NSString*)value;

- (NSString*)primitiveUid;
- (void)setPrimitiveUid:(NSString*)value;

- (OpenChapter*)primitiveChapter;
- (void)setPrimitiveChapter:(OpenChapter*)value;

@end