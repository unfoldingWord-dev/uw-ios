
#import "_UWTopContainer.h"

@class UWLanguage, UWVersion;

@interface UWTopContainer : _UWTopContainer {}

@property (nonatomic, assign, readonly) BOOL isUSFM;
@property (nonatomic, strong, readonly) NSArray *sortedLanguages;

+ (void)updateFromArray:(NSArray *)array;

- (NSDictionary *)jsonRepresentionWithoutLanguages;

// These methods are used when importing a file to get a handle to the objects we imported
+ (instancetype)topContainerForDictionary:(NSDictionary *)dictionary;
- (UWLanguage *) languageForDictionary:(NSDictionary *)dictionary;
- (UWVersion *) versionForDictionary:(NSDictionary *)dictionary;

@end
