
#import "_UWTopContainer.h"

@class UWLanguage, UWVersion;

@interface UWTopContainer : _UWTopContainer {}

@property (nonatomic, assign, readonly) BOOL isUSFM;
@property (nonatomic, strong, readonly) NSArray<UWLanguage *>  * _Nonnull sortedLanguages;

/// Returns all top-level containers sorted
+ (NSArray<UWTopContainer *> * _Nonnull)sortedContainers;

+ (void)updateFromArray:(NSArray * _Nonnull)array;

- (NSDictionary * _Nonnull)jsonRepresentionWithoutLanguages;

// These methods are used when importing a file to get a handle to the objects we imported
+ (instancetype __nullable)topContainerForDictionary:(NSDictionary * _Nonnull)dictionary;
- (UWLanguage * __nullable) languageForDictionary:(NSDictionary * _Nonnull)dictionary;
- (UWVersion * __nullable) versionForDictionary:(NSDictionary * _Nonnull)dictionary;

@end
