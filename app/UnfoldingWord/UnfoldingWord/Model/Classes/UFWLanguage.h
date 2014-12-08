//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

#import "_UFWLanguage.h"

@interface UFWLanguage : _UFWLanguage {}

+ (NSString *)languageNameForDictionary:(NSDictionary *)dictionary;

- (BOOL)doesNeedUpdateWithDictionary:(NSDictionary *)dictionary;

+ (void)createOrUpdateLanguageWithDictionary:(NSDictionary *)dictionary;

+ (void)updateLanguage:(UFWLanguage *)language withDictionary:(NSDictionary *)dictionary;

+(UFWLanguage *)languageForName:(NSString *)language;

+(NSArray *)allLanguages;

@end
