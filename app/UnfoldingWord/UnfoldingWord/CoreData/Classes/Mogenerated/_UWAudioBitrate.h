//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UWAudioBitrate.h instead.

#import <CoreData/CoreData.h>

extern const struct UWAudioBitrateAttributes {
	__unsafe_unretained NSString *filename;
	__unsafe_unretained NSString *isDownloaded;
	__unsafe_unretained NSString *isValid;
	__unsafe_unretained NSString *mod;
	__unsafe_unretained NSString *rate;
	__unsafe_unretained NSString *signature;
	__unsafe_unretained NSString *size;
} UWAudioBitrateAttributes;

extern const struct UWAudioBitrateRelationships {
	__unsafe_unretained NSString *source;
} UWAudioBitrateRelationships;

extern const struct UWAudioBitrateFetchedProperties {
} UWAudioBitrateFetchedProperties;

@class UWAudioSource;

@interface _UWAudioBitrate : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;

@property (nonatomic, strong) NSString* filename;

//- (BOOL)validateFilename:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* isDownloaded;

@property BOOL isDownloadedValue;
- (BOOL)isDownloadedValue;
- (void)setIsDownloadedValue:(BOOL)value_;

//- (BOOL)validateIsDownloaded:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* isValid;

@property BOOL isValidValue;
- (BOOL)isValidValue;
- (void)setIsValidValue:(BOOL)value_;

//- (BOOL)validateIsValid:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* mod;

@property int64_t modValue;
- (int64_t)modValue;
- (void)setModValue:(int64_t)value_;

//- (BOOL)validateMod:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* rate;

@property int64_t rateValue;
- (int64_t)rateValue;
- (void)setRateValue:(int64_t)value_;

//- (BOOL)validateRate:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* signature;

//- (BOOL)validateSignature:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* size;

@property int64_t sizeValue;
- (int64_t)sizeValue;
- (void)setSizeValue:(int64_t)value_;

//- (BOOL)validateSize:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) UWAudioSource* source;

//- (BOOL)validateSource:(id*)value_ error:(NSError**)error_;

@end

@interface _UWAudioBitrate (CoreDataGeneratedAccessors)

@end

@interface _UWAudioBitrate (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveFilename;
- (void)setPrimitiveFilename:(NSString*)value;

- (NSNumber*)primitiveIsDownloaded;
- (void)setPrimitiveIsDownloaded:(NSNumber*)value;

- (BOOL)primitiveIsDownloadedValue;
- (void)setPrimitiveIsDownloadedValue:(BOOL)value_;

- (NSNumber*)primitiveIsValid;
- (void)setPrimitiveIsValid:(NSNumber*)value;

- (BOOL)primitiveIsValidValue;
- (void)setPrimitiveIsValidValue:(BOOL)value_;

- (NSNumber*)primitiveMod;
- (void)setPrimitiveMod:(NSNumber*)value;

- (int64_t)primitiveModValue;
- (void)setPrimitiveModValue:(int64_t)value_;

- (NSNumber*)primitiveRate;
- (void)setPrimitiveRate:(NSNumber*)value;

- (int64_t)primitiveRateValue;
- (void)setPrimitiveRateValue:(int64_t)value_;

- (NSString*)primitiveSignature;
- (void)setPrimitiveSignature:(NSString*)value;

- (NSNumber*)primitiveSize;
- (void)setPrimitiveSize:(NSNumber*)value;

- (int64_t)primitiveSizeValue;
- (void)setPrimitiveSizeValue:(int64_t)value_;

- (UWAudioSource*)primitiveSource;
- (void)setPrimitiveSource:(UWAudioSource*)value;

@end