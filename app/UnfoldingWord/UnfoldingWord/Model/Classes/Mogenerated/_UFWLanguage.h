//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UFWLanguage.h instead.

#import <CoreData/CoreData.h>

extern const struct UFWLanguageAttributes {
	__unsafe_unretained NSString *checking_entity;
	__unsafe_unretained NSString *checking_level;
	__unsafe_unretained NSString *date_modified;
	__unsafe_unretained NSString *direction;
	__unsafe_unretained NSString *language;
	__unsafe_unretained NSString *language_string;
	__unsafe_unretained NSString *publish_date;
	__unsafe_unretained NSString *version;
} UFWLanguageAttributes;

extern const struct UFWLanguageRelationships {
	__unsafe_unretained NSString *bible;
} UFWLanguageRelationships;

extern const struct UFWLanguageFetchedProperties {
} UFWLanguageFetchedProperties;

@class UFWBible;

@interface UFWLanguageID : NSManagedObjectID {}
@end

@interface _UFWLanguage : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (UFWLanguageID*)objectID;

@property (nonatomic, strong) NSString* checking_entity;

//- (BOOL)validateChecking_entity:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* checking_level;

//- (BOOL)validateChecking_level:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* date_modified;

//- (BOOL)validateDate_modified:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* direction;

//- (BOOL)validateDirection:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* language;

//- (BOOL)validateLanguage:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* language_string;

//- (BOOL)validateLanguage_string:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* publish_date;

//- (BOOL)validatePublish_date:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* version;

//- (BOOL)validateVersion:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) UFWBible* bible;

//- (BOOL)validateBible:(id*)value_ error:(NSError**)error_;

@end

@interface _UFWLanguage (CoreDataGeneratedAccessors)

@end

@interface _UFWLanguage (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveChecking_entity;
- (void)setPrimitiveChecking_entity:(NSString*)value;

- (NSString*)primitiveChecking_level;
- (void)setPrimitiveChecking_level:(NSString*)value;

- (NSString*)primitiveDate_modified;
- (void)setPrimitiveDate_modified:(NSString*)value;

- (NSString*)primitiveDirection;
- (void)setPrimitiveDirection:(NSString*)value;

- (NSString*)primitiveLanguage;
- (void)setPrimitiveLanguage:(NSString*)value;

- (NSString*)primitiveLanguage_string;
- (void)setPrimitiveLanguage_string:(NSString*)value;

- (NSString*)primitivePublish_date;
- (void)setPrimitivePublish_date:(NSString*)value;

- (NSString*)primitiveVersion;
- (void)setPrimitiveVersion:(NSString*)value;

- (UFWBible*)primitiveBible;
- (void)setPrimitiveBible:(UFWBible*)value;

@end