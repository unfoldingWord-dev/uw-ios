//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UWAudioSource.h instead.

#import <CoreData/CoreData.h>

extern const struct UWAudioSourceAttributes {
	__unsafe_unretained NSString *bitrate;
	__unsafe_unretained NSString *chapter;
	__unsafe_unretained NSString *length;
	__unsafe_unretained NSString *mod;
	__unsafe_unretained NSString *size;
	__unsafe_unretained NSString *src;
	__unsafe_unretained NSString *src_sig;
} UWAudioSourceAttributes;

extern const struct UWAudioSourceRelationships {
	__unsafe_unretained NSString *audio;
} UWAudioSourceRelationships;

extern const struct UWAudioSourceFetchedProperties {
} UWAudioSourceFetchedProperties;

@class UWAudio;

@interface _UWAudioSource : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;

@property (nonatomic, strong) NSNumber* bitrate;

@property int64_t bitrateValue;
- (int64_t)bitrateValue;
- (void)setBitrateValue:(int64_t)value_;

//- (BOOL)validateBitrate:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* chapter;

//- (BOOL)validateChapter:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* length;

@property int64_t lengthValue;
- (int64_t)lengthValue;
- (void)setLengthValue:(int64_t)value_;

//- (BOOL)validateLength:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* mod;

@property double modValue;
- (double)modValue;
- (void)setModValue:(double)value_;

//- (BOOL)validateMod:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* size;

@property int64_t sizeValue;
- (int64_t)sizeValue;
- (void)setSizeValue:(int64_t)value_;

//- (BOOL)validateSize:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* src;

//- (BOOL)validateSrc:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* src_sig;

//- (BOOL)validateSrc_sig:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) UWAudio* audio;

//- (BOOL)validateAudio:(id*)value_ error:(NSError**)error_;

@end

@interface _UWAudioSource (CoreDataGeneratedAccessors)

@end

@interface _UWAudioSource (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveBitrate;
- (void)setPrimitiveBitrate:(NSNumber*)value;

- (int64_t)primitiveBitrateValue;
- (void)setPrimitiveBitrateValue:(int64_t)value_;

- (NSString*)primitiveChapter;
- (void)setPrimitiveChapter:(NSString*)value;

- (NSNumber*)primitiveLength;
- (void)setPrimitiveLength:(NSNumber*)value;

- (int64_t)primitiveLengthValue;
- (void)setPrimitiveLengthValue:(int64_t)value_;

- (NSNumber*)primitiveMod;
- (void)setPrimitiveMod:(NSNumber*)value;

- (double)primitiveModValue;
- (void)setPrimitiveModValue:(double)value_;

- (NSNumber*)primitiveSize;
- (void)setPrimitiveSize:(NSNumber*)value;

- (int64_t)primitiveSizeValue;
- (void)setPrimitiveSizeValue:(int64_t)value_;

- (NSString*)primitiveSrc;
- (void)setPrimitiveSrc:(NSString*)value;

- (NSString*)primitiveSrc_sig;
- (void)setPrimitiveSrc_sig:(NSString*)value;

- (UWAudio*)primitiveAudio;
- (void)setPrimitiveAudio:(UWAudio*)value;

@end