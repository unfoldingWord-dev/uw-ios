//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UWVideo.h instead.

#import <CoreData/CoreData.h>

extern const struct UWVideoAttributes {
	__unsafe_unretained NSString *contributors;
	__unsafe_unretained NSString *rev;
	__unsafe_unretained NSString *txt_ver;
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

@property (nonatomic, strong) NSString* contributors;

//- (BOOL)validateContributors:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* rev;

//- (BOOL)validateRev:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* txt_ver;

//- (BOOL)validateTxt_ver:(id*)value_ error:(NSError**)error_;

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

- (NSString*)primitiveContributors;
- (void)setPrimitiveContributors:(NSString*)value;

- (NSString*)primitiveRev;
- (void)setPrimitiveRev:(NSString*)value;

- (NSString*)primitiveTxt_ver;
- (void)setPrimitiveTxt_ver:(NSString*)value;

- (UWTOCMedia*)primitiveMedia;
- (void)setPrimitiveMedia:(UWTOCMedia*)value;

- (NSMutableSet*)primitiveSources;
- (void)setPrimitiveSources:(NSMutableSet*)value;

@end