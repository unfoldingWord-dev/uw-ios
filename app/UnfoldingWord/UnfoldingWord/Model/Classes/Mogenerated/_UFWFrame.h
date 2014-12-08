//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UFWFrame.h instead.

#import <CoreData/CoreData.h>

extern const struct UFWFrameAttributes {
	__unsafe_unretained NSString *imageUrl;
	__unsafe_unretained NSString *text;
	__unsafe_unretained NSString *uid;
} UFWFrameAttributes;

extern const struct UFWFrameRelationships {
	__unsafe_unretained NSString *chapter;
} UFWFrameRelationships;

extern const struct UFWFrameFetchedProperties {
} UFWFrameFetchedProperties;

@class UFWChapter;

@interface UFWFrameID : NSManagedObjectID {}
@end

@interface _UFWFrame : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (UFWFrameID*)objectID;

@property (nonatomic, strong) NSString* imageUrl;

//- (BOOL)validateImageUrl:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* text;

//- (BOOL)validateText:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* uid;

//- (BOOL)validateUid:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) UFWChapter* chapter;

//- (BOOL)validateChapter:(id*)value_ error:(NSError**)error_;

@end

@interface _UFWFrame (CoreDataGeneratedAccessors)

@end

@interface _UFWFrame (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveImageUrl;
- (void)setPrimitiveImageUrl:(NSString*)value;

- (NSString*)primitiveText;
- (void)setPrimitiveText:(NSString*)value;

- (NSString*)primitiveUid;
- (void)setPrimitiveUid:(NSString*)value;

- (UFWChapter*)primitiveChapter;
- (void)setPrimitiveChapter:(UFWChapter*)value;

@end