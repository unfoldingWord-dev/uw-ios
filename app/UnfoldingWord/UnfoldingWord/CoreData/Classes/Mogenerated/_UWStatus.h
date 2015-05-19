//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UWStatus.h instead.

#import <CoreData/CoreData.h>

extern const struct UWStatusAttributes {
	__unsafe_unretained NSString *checking_entity;
	__unsafe_unretained NSString *checking_level;
	__unsafe_unretained NSString *comments;
	__unsafe_unretained NSString *contributors;
	__unsafe_unretained NSString *publish_date;
	__unsafe_unretained NSString *source_text;
	__unsafe_unretained NSString *source_text_version;
	__unsafe_unretained NSString *version;
} UWStatusAttributes;

extern const struct UWStatusRelationships {
	__unsafe_unretained NSString *uwversion;
} UWStatusRelationships;

extern const struct UWStatusFetchedProperties {
} UWStatusFetchedProperties;

@class UWVersion;

@interface _UWStatus : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;

@property (nonatomic, strong) NSString* checking_entity;

//- (BOOL)validateChecking_entity:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* checking_level;

//- (BOOL)validateChecking_level:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* comments;

//- (BOOL)validateComments:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* contributors;

//- (BOOL)validateContributors:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* publish_date;

//- (BOOL)validatePublish_date:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* source_text;

//- (BOOL)validateSource_text:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* source_text_version;

//- (BOOL)validateSource_text_version:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* version;

//- (BOOL)validateVersion:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) UWVersion* uwversion;

//- (BOOL)validateUwversion:(id*)value_ error:(NSError**)error_;

@end

@interface _UWStatus (CoreDataGeneratedAccessors)

@end

@interface _UWStatus (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveChecking_entity;
- (void)setPrimitiveChecking_entity:(NSString*)value;

- (NSString*)primitiveChecking_level;
- (void)setPrimitiveChecking_level:(NSString*)value;

- (NSString*)primitiveComments;
- (void)setPrimitiveComments:(NSString*)value;

- (NSString*)primitiveContributors;
- (void)setPrimitiveContributors:(NSString*)value;

- (NSString*)primitivePublish_date;
- (void)setPrimitivePublish_date:(NSString*)value;

- (NSString*)primitiveSource_text;
- (void)setPrimitiveSource_text:(NSString*)value;

- (NSString*)primitiveSource_text_version;
- (void)setPrimitiveSource_text_version:(NSString*)value;

- (NSString*)primitiveVersion;
- (void)setPrimitiveVersion:(NSString*)value;

- (UWVersion*)primitiveUwversion;
- (void)setPrimitiveUwversion:(UWVersion*)value;

@end