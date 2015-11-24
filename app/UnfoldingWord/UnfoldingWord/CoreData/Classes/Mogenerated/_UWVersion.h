//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UWVersion.h instead.

#import <CoreData/CoreData.h>

extern const struct UWVersionAttributes {
	__unsafe_unretained NSString *mod;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *slug;
	__unsafe_unretained NSString *sortOrder;
} UWVersionAttributes;

extern const struct UWVersionRelationships {
	__unsafe_unretained NSString *language;
	__unsafe_unretained NSString *status;
	__unsafe_unretained NSString *toc;
} UWVersionRelationships;

extern const struct UWVersionFetchedProperties {
} UWVersionFetchedProperties;

@class UWLanguage;
@class UWStatus;
@class UWTOC;

@interface _UWVersion : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;

@property (nonatomic, strong) NSString* mod;

//- (BOOL)validateMod:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* slug;

//- (BOOL)validateSlug:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* sortOrder;

@property int32_t sortOrderValue;
- (int32_t)sortOrderValue;
- (void)setSortOrderValue:(int32_t)value_;

//- (BOOL)validateSortOrder:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) UWLanguage* language;

//- (BOOL)validateLanguage:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) UWStatus* status;

//- (BOOL)validateStatus:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet<UWTOC *>* toc;

- (NSMutableSet*)tocSet;

@end

@interface _UWVersion (CoreDataGeneratedAccessors)

- (void)addToc:(NSSet*)value_;
- (void)removeToc:(NSSet*)value_;
- (void)addTocObject:(UWTOC*)value_;
- (void)removeTocObject:(UWTOC*)value_;

@end

@interface _UWVersion (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveMod;
- (void)setPrimitiveMod:(NSString*)value;

- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;

- (NSString*)primitiveSlug;
- (void)setPrimitiveSlug:(NSString*)value;

- (NSNumber*)primitiveSortOrder;
- (void)setPrimitiveSortOrder:(NSNumber*)value;

- (int32_t)primitiveSortOrderValue;
- (void)setPrimitiveSortOrderValue:(int32_t)value_;

- (UWLanguage*)primitiveLanguage;
- (void)setPrimitiveLanguage:(UWLanguage*)value;

- (UWStatus*)primitiveStatus;
- (void)setPrimitiveStatus:(UWStatus*)value;

- (NSMutableSet*)primitiveToc;
- (void)setPrimitiveToc:(NSMutableSet*)value;

@end