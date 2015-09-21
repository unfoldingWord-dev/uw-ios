//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UWTOC.h instead.

#import <CoreData/CoreData.h>

extern const struct UWTOCAttributes {
	__unsafe_unretained NSString *isContentChanged;
	__unsafe_unretained NSString *isContentValid;
	__unsafe_unretained NSString *isDownloadFailed;
	__unsafe_unretained NSString *isDownloaded;
	__unsafe_unretained NSString *isUSFM;
	__unsafe_unretained NSString *mod;
	__unsafe_unretained NSString *slug;
	__unsafe_unretained NSString *sortOrder;
	__unsafe_unretained NSString *src;
	__unsafe_unretained NSString *src_sig;
	__unsafe_unretained NSString *title;
	__unsafe_unretained NSString *uwDescription;
} UWTOCAttributes;

extern const struct UWTOCRelationships {
	__unsafe_unretained NSString *media;
	__unsafe_unretained NSString *openContainer;
	__unsafe_unretained NSString *usfmInfo;
	__unsafe_unretained NSString *version;
} UWTOCRelationships;

extern const struct UWTOCFetchedProperties {
} UWTOCFetchedProperties;

@class UWTOCMedia;
@class OpenContainer;
@class USFMInfo;
@class UWVersion;

@interface _UWTOC : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;

@property (nonatomic, strong) NSNumber* isContentChanged;

@property BOOL isContentChangedValue;
- (BOOL)isContentChangedValue;
- (void)setIsContentChangedValue:(BOOL)value_;

//- (BOOL)validateIsContentChanged:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* isContentValid;

@property BOOL isContentValidValue;
- (BOOL)isContentValidValue;
- (void)setIsContentValidValue:(BOOL)value_;

//- (BOOL)validateIsContentValid:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* isDownloadFailed;

@property BOOL isDownloadFailedValue;
- (BOOL)isDownloadFailedValue;
- (void)setIsDownloadFailedValue:(BOOL)value_;

//- (BOOL)validateIsDownloadFailed:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* isDownloaded;

@property BOOL isDownloadedValue;
- (BOOL)isDownloadedValue;
- (void)setIsDownloadedValue:(BOOL)value_;

//- (BOOL)validateIsDownloaded:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* isUSFM;

@property BOOL isUSFMValue;
- (BOOL)isUSFMValue;
- (void)setIsUSFMValue:(BOOL)value_;

//- (BOOL)validateIsUSFM:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* mod;

//- (BOOL)validateMod:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* slug;

//- (BOOL)validateSlug:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* sortOrder;

@property int32_t sortOrderValue;
- (int32_t)sortOrderValue;
- (void)setSortOrderValue:(int32_t)value_;

//- (BOOL)validateSortOrder:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* src;

//- (BOOL)validateSrc:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* src_sig;

//- (BOOL)validateSrc_sig:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* title;

//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* uwDescription;

//- (BOOL)validateUwDescription:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) UWTOCMedia* media;

//- (BOOL)validateMedia:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) OpenContainer* openContainer;

//- (BOOL)validateOpenContainer:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) USFMInfo* usfmInfo;

//- (BOOL)validateUsfmInfo:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) UWVersion* version;

//- (BOOL)validateVersion:(id*)value_ error:(NSError**)error_;

@end

@interface _UWTOC (CoreDataGeneratedAccessors)

@end

@interface _UWTOC (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveIsContentChanged;
- (void)setPrimitiveIsContentChanged:(NSNumber*)value;

- (BOOL)primitiveIsContentChangedValue;
- (void)setPrimitiveIsContentChangedValue:(BOOL)value_;

- (NSNumber*)primitiveIsContentValid;
- (void)setPrimitiveIsContentValid:(NSNumber*)value;

- (BOOL)primitiveIsContentValidValue;
- (void)setPrimitiveIsContentValidValue:(BOOL)value_;

- (NSNumber*)primitiveIsDownloadFailed;
- (void)setPrimitiveIsDownloadFailed:(NSNumber*)value;

- (BOOL)primitiveIsDownloadFailedValue;
- (void)setPrimitiveIsDownloadFailedValue:(BOOL)value_;

- (NSNumber*)primitiveIsDownloaded;
- (void)setPrimitiveIsDownloaded:(NSNumber*)value;

- (BOOL)primitiveIsDownloadedValue;
- (void)setPrimitiveIsDownloadedValue:(BOOL)value_;

- (NSNumber*)primitiveIsUSFM;
- (void)setPrimitiveIsUSFM:(NSNumber*)value;

- (BOOL)primitiveIsUSFMValue;
- (void)setPrimitiveIsUSFMValue:(BOOL)value_;

- (NSString*)primitiveMod;
- (void)setPrimitiveMod:(NSString*)value;

- (NSString*)primitiveSlug;
- (void)setPrimitiveSlug:(NSString*)value;

- (NSNumber*)primitiveSortOrder;
- (void)setPrimitiveSortOrder:(NSNumber*)value;

- (int32_t)primitiveSortOrderValue;
- (void)setPrimitiveSortOrderValue:(int32_t)value_;

- (NSString*)primitiveSrc;
- (void)setPrimitiveSrc:(NSString*)value;

- (NSString*)primitiveSrc_sig;
- (void)setPrimitiveSrc_sig:(NSString*)value;

- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;

- (NSString*)primitiveUwDescription;
- (void)setPrimitiveUwDescription:(NSString*)value;

- (UWTOCMedia*)primitiveMedia;
- (void)setPrimitiveMedia:(UWTOCMedia*)value;

- (OpenContainer*)primitiveOpenContainer;
- (void)setPrimitiveOpenContainer:(OpenContainer*)value;

- (USFMInfo*)primitiveUsfmInfo;
- (void)setPrimitiveUsfmInfo:(USFMInfo*)value;

- (UWVersion*)primitiveVersion;
- (void)setPrimitiveVersion:(UWVersion*)value;

@end