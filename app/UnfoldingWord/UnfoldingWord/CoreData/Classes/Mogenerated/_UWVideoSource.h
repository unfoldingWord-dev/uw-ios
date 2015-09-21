//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UWVideoSource.h instead.

#import <CoreData/CoreData.h>

extern const struct UWVideoSourceAttributes {
	__unsafe_unretained NSString *mod;
	__unsafe_unretained NSString *src;
	__unsafe_unretained NSString *src_sig;
} UWVideoSourceAttributes;

extern const struct UWVideoSourceRelationships {
	__unsafe_unretained NSString *video;
} UWVideoSourceRelationships;

extern const struct UWVideoSourceFetchedProperties {
} UWVideoSourceFetchedProperties;

@class UWVideo;

@interface _UWVideoSource : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;

@property (nonatomic, strong) NSNumber* mod;

@property double modValue;
- (double)modValue;
- (void)setModValue:(double)value_;

//- (BOOL)validateMod:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* src;

//- (BOOL)validateSrc:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* src_sig;

//- (BOOL)validateSrc_sig:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) UWVideo* video;

//- (BOOL)validateVideo:(id*)value_ error:(NSError**)error_;

@end

@interface _UWVideoSource (CoreDataGeneratedAccessors)

@end

@interface _UWVideoSource (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveMod;
- (void)setPrimitiveMod:(NSNumber*)value;

- (double)primitiveModValue;
- (void)setPrimitiveModValue:(double)value_;

- (NSString*)primitiveSrc;
- (void)setPrimitiveSrc:(NSString*)value;

- (NSString*)primitiveSrc_sig;
- (void)setPrimitiveSrc_sig:(NSString*)value;

- (UWVideo*)primitiveVideo;
- (void)setPrimitiveVideo:(UWVideo*)value;

@end