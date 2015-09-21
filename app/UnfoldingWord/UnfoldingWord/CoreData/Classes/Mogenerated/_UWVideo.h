//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UWVideo.h instead.

#import <CoreData/CoreData.h>

extern const struct UWVideoAttributes {
} UWVideoAttributes;

extern const struct UWVideoRelationships {
	__unsafe_unretained NSString *media;
	__unsafe_unretained NSString *sources;
} UWVideoRelationships;

extern const struct UWVideoFetchedProperties {
} UWVideoFetchedProperties;

@class UWTOCMedia;
@class UWVideoSource;

@interface _UWVideo : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;

@property (nonatomic, strong) UWTOCMedia* media;

//- (BOOL)validateMedia:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet* sources;

- (NSMutableSet*)sourcesSet;

@end

@interface _UWVideo (CoreDataGeneratedAccessors)

- (void)addSources:(NSSet*)value_;
- (void)removeSources:(NSSet*)value_;
- (void)addSourcesObject:(UWVideoSource*)value_;
- (void)removeSourcesObject:(UWVideoSource*)value_;

@end

@interface _UWVideo (CoreDataGeneratedPrimitiveAccessors)

- (UWTOCMedia*)primitiveMedia;
- (void)setPrimitiveMedia:(UWTOCMedia*)value;

- (NSMutableSet*)primitiveSources;
- (void)setPrimitiveSources:(NSMutableSet*)value;

@end