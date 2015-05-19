//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UWLanguage.h instead.

#import <CoreData/CoreData.h>

extern const struct UWLanguageAttributes {
	__unsafe_unretained NSString *lc;
	__unsafe_unretained NSString *mod;
	__unsafe_unretained NSString *sortOrder;
} UWLanguageAttributes;

extern const struct UWLanguageRelationships {
	__unsafe_unretained NSString *topContainer;
	__unsafe_unretained NSString *versions;
} UWLanguageRelationships;

extern const struct UWLanguageFetchedProperties {
} UWLanguageFetchedProperties;

@class UWTopContainer;
@class UWVersion;

@interface _UWLanguage : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;

@property (nonatomic, strong) NSString* lc;

//- (BOOL)validateLc:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* mod;

//- (BOOL)validateMod:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* sortOrder;

@property int32_t sortOrderValue;
- (int32_t)sortOrderValue;
- (void)setSortOrderValue:(int32_t)value_;

//- (BOOL)validateSortOrder:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) UWTopContainer* topContainer;

//- (BOOL)validateTopContainer:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet* versions;

- (NSMutableSet*)versionsSet;

@end

@interface _UWLanguage (CoreDataGeneratedAccessors)

- (void)addVersions:(NSSet*)value_;
- (void)removeVersions:(NSSet*)value_;
- (void)addVersionsObject:(UWVersion*)value_;
- (void)removeVersionsObject:(UWVersion*)value_;

@end

@interface _UWLanguage (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveLc;
- (void)setPrimitiveLc:(NSString*)value;

- (NSString*)primitiveMod;
- (void)setPrimitiveMod:(NSString*)value;

- (NSNumber*)primitiveSortOrder;
- (void)setPrimitiveSortOrder:(NSNumber*)value;

- (int32_t)primitiveSortOrderValue;
- (void)setPrimitiveSortOrderValue:(int32_t)value_;

- (UWTopContainer*)primitiveTopContainer;
- (void)setPrimitiveTopContainer:(UWTopContainer*)value;

- (NSMutableSet*)primitiveVersions;
- (void)setPrimitiveVersions:(NSMutableSet*)value;

@end