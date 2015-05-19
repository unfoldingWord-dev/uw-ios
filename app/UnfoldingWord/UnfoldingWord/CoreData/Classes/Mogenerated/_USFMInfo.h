//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to USFMInfo.h instead.

#import <CoreData/CoreData.h>

extern const struct USFMInfoAttributes {
	__unsafe_unretained NSString *filename;
	__unsafe_unretained NSString *numberOfChapters;
	__unsafe_unretained NSString *signature;
} USFMInfoAttributes;

extern const struct USFMInfoRelationships {
	__unsafe_unretained NSString *toc;
} USFMInfoRelationships;

extern const struct USFMInfoFetchedProperties {
} USFMInfoFetchedProperties;

@class UWTOC;

@interface _USFMInfo : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;

@property (nonatomic, strong) NSString* filename;

//- (BOOL)validateFilename:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* numberOfChapters;

@property int32_t numberOfChaptersValue;
- (int32_t)numberOfChaptersValue;
- (void)setNumberOfChaptersValue:(int32_t)value_;

//- (BOOL)validateNumberOfChapters:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* signature;

//- (BOOL)validateSignature:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) UWTOC* toc;

//- (BOOL)validateToc:(id*)value_ error:(NSError**)error_;

@end

@interface _USFMInfo (CoreDataGeneratedAccessors)

@end

@interface _USFMInfo (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveFilename;
- (void)setPrimitiveFilename:(NSString*)value;

- (NSNumber*)primitiveNumberOfChapters;
- (void)setPrimitiveNumberOfChapters:(NSNumber*)value;

- (int32_t)primitiveNumberOfChaptersValue;
- (void)setPrimitiveNumberOfChaptersValue:(int32_t)value_;

- (NSString*)primitiveSignature;
- (void)setPrimitiveSignature:(NSString*)value;

- (UWTOC*)primitiveToc;
- (void)setPrimitiveToc:(UWTOC*)value;

@end