//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UWAudio.h instead.

#import <CoreData/CoreData.h>

extern const struct UWAudioAttributes {
	__unsafe_unretained NSString *contributors;
	__unsafe_unretained NSString *rev;
	__unsafe_unretained NSString *txt_ver;
} UWAudioAttributes;

extern const struct UWAudioRelationships {
	__unsafe_unretained NSString *media;
	__unsafe_unretained NSString *sources;
} UWAudioRelationships;

extern const struct UWAudioFetchedProperties {
} UWAudioFetchedProperties;

@class UWTOCMedia;
@class UWAudioSource;

@interface _UWAudio : NSManagedObject {}
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

@property (nonatomic, strong) NSSet<UWAudioSource *>* sources;

- (NSMutableSet*)sourcesSet;

@end

@interface _UWAudio (CoreDataGeneratedAccessors)

- (void)addSources:(NSSet*)value_;
- (void)removeSources:(NSSet*)value_;
- (void)addSourcesObject:(UWAudioSource*)value_;
- (void)removeSourcesObject:(UWAudioSource*)value_;

@end

@interface _UWAudio (CoreDataGeneratedPrimitiveAccessors)

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