//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UWTOCMedia.h instead.

#import <CoreData/CoreData.h>

extern const struct UWTOCMediaAttributes {
} UWTOCMediaAttributes;

extern const struct UWTOCMediaRelationships {
	__unsafe_unretained NSString *audio;
	__unsafe_unretained NSString *toc;
	__unsafe_unretained NSString *video;
} UWTOCMediaRelationships;

extern const struct UWTOCMediaFetchedProperties {
} UWTOCMediaFetchedProperties;

@class UWAudio;
@class UWTOC;
@class UWVideo;

@interface _UWTOCMedia : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;

@property (nonatomic, strong) UWAudio* audio;

//- (BOOL)validateAudio:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) UWTOC* toc;

//- (BOOL)validateToc:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) UWVideo* video;

//- (BOOL)validateVideo:(id*)value_ error:(NSError**)error_;

@end

@interface _UWTOCMedia (CoreDataGeneratedAccessors)

@end

@interface _UWTOCMedia (CoreDataGeneratedPrimitiveAccessors)

- (UWAudio*)primitiveAudio;
- (void)setPrimitiveAudio:(UWAudio*)value;

- (UWTOC*)primitiveToc;
- (void)setPrimitiveToc:(UWTOC*)value;

- (UWVideo*)primitiveVideo;
- (void)setPrimitiveVideo:(UWVideo*)value;

@end