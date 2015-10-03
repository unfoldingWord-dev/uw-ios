//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UWAudioSource.h instead.

#import <CoreData/CoreData.h>

extern const struct UWAudioSourceAttributes {
	__unsafe_unretained NSString *chapter;
	__unsafe_unretained NSString *length;
	__unsafe_unretained NSString *src;
	__unsafe_unretained NSString *src_sig;
} UWAudioSourceAttributes;

extern const struct UWAudioSourceRelationships {
	__unsafe_unretained NSString *audio;
	__unsafe_unretained NSString *bitrates;
} UWAudioSourceRelationships;

extern const struct UWAudioSourceFetchedProperties {
} UWAudioSourceFetchedProperties;

@class UWAudio;
@class UWAudioBitrate;

@interface _UWAudioSource : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;

@property (nonatomic, strong) NSString* chapter;

//- (BOOL)validateChapter:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* length;

@property int64_t lengthValue;
- (int64_t)lengthValue;
- (void)setLengthValue:(int64_t)value_;

//- (BOOL)validateLength:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* src;

//- (BOOL)validateSrc:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* src_sig;

//- (BOOL)validateSrc_sig:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) UWAudio* audio;

//- (BOOL)validateAudio:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet* bitrates;

- (NSMutableSet*)bitratesSet;

@end

@interface _UWAudioSource (CoreDataGeneratedAccessors)

- (void)addBitrates:(NSSet*)value_;
- (void)removeBitrates:(NSSet*)value_;
- (void)addBitratesObject:(UWAudioBitrate*)value_;
- (void)removeBitratesObject:(UWAudioBitrate*)value_;

@end

@interface _UWAudioSource (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveChapter;
- (void)setPrimitiveChapter:(NSString*)value;

- (NSNumber*)primitiveLength;
- (void)setPrimitiveLength:(NSNumber*)value;

- (int64_t)primitiveLengthValue;
- (void)setPrimitiveLengthValue:(int64_t)value_;

- (NSString*)primitiveSrc;
- (void)setPrimitiveSrc:(NSString*)value;

- (NSString*)primitiveSrc_sig;
- (void)setPrimitiveSrc_sig:(NSString*)value;

- (UWAudio*)primitiveAudio;
- (void)setPrimitiveAudio:(UWAudio*)value;

- (NSMutableSet*)primitiveBitrates;
- (void)setPrimitiveBitrates:(NSMutableSet*)value;

@end