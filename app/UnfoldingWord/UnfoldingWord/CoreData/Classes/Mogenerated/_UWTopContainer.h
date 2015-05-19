//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UWTopContainer.h instead.

#import <CoreData/CoreData.h>

extern const struct UWTopContainerAttributes {
	__unsafe_unretained NSString *slug;
	__unsafe_unretained NSString *sortOrder;
	__unsafe_unretained NSString *title;
} UWTopContainerAttributes;

extern const struct UWTopContainerRelationships {
	__unsafe_unretained NSString *languages;
} UWTopContainerRelationships;

extern const struct UWTopContainerFetchedProperties {
} UWTopContainerFetchedProperties;

@class UWLanguage;

@interface _UWTopContainer : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;

@property (nonatomic, strong) NSString* slug;

//- (BOOL)validateSlug:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* sortOrder;

@property int32_t sortOrderValue;
- (int32_t)sortOrderValue;
- (void)setSortOrderValue:(int32_t)value_;

//- (BOOL)validateSortOrder:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* title;

//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet* languages;

- (NSMutableSet*)languagesSet;

@end

@interface _UWTopContainer (CoreDataGeneratedAccessors)

- (void)addLanguages:(NSSet*)value_;
- (void)removeLanguages:(NSSet*)value_;
- (void)addLanguagesObject:(UWLanguage*)value_;
- (void)removeLanguagesObject:(UWLanguage*)value_;

@end

@interface _UWTopContainer (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveSlug;
- (void)setPrimitiveSlug:(NSString*)value;

- (NSNumber*)primitiveSortOrder;
- (void)setPrimitiveSortOrder:(NSNumber*)value;

- (int32_t)primitiveSortOrderValue;
- (void)setPrimitiveSortOrderValue:(int32_t)value_;

- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;

- (NSMutableSet*)primitiveLanguages;
- (void)setPrimitiveLanguages:(NSMutableSet*)value;

@end