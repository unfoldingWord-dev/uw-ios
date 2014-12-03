//
//  DataHandler.m
//  UnfoldingWord
//
//  Created by Acts Media Inc. on 26/11/14.
//  Copyright (c) 2014 Distant Shores Media All rights reserved.
//

#import "DataHandler.h"
#import "Constants.h"
#import "ModelHandler.h"
#import "LanguageModel.h"
#import "Utils.h"
#import "CommunicationHandler.h"

@implementation DataHandler

+(NSArray*)getLanguageList
{
    return [ModelHandler fetchLanguages];
}

+(NSString *)getChapterAPIsting:(NSString*)language
{
  return  [NSString stringWithFormat:@"%@%@/obs-%@.json",BASE_URL,language,language];
}

+(void)handleLanguages:(NSArray *)languages
{
    NSMutableArray *lastUpdatedLanguageList = [ModelHandler fetchLanguages];
    if([lastUpdatedLanguageList count])
    {
        for(NSDictionary *language in languages)
        {
            NSString *currentLang = [language valueForKey:k_KEY_LANGUAGE];
            NSDate *latestDate = [Utils dateWithString:[language  valueForKey:k_KEY_DATE_MODIFIED]
                                   withFormatterString:@"YYYYMMdd"
                                              timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            
            for(LanguageModel *lModel in lastUpdatedLanguageList)
            {
                if([currentLang isEqualToString:lModel.language])
                {
                    NSDate *storedDate = [Utils dateWithString:lModel.date_modified
                                           withFormatterString:@"YYYYMMdd"
                                                      timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                    
                    
                    if (1)//[latestDate compare:storedDate] == NSOrderedDescending)
                    {
                        [CommunicationHandler callChapterAPI:[self getChapterAPIsting:lModel.language] With:^(NSDictionary *responseData, NSError *error)
                        {
                            if(error)
                            {
                                
                            }
                            else
                            {
                                //Save Data to CoreData
                                [ModelHandler insertBiblicalData:responseData LanguageCode:lModel.language];
                            }
                            
                        }];
                        
                    }
                }
                
            }

        }
    }
    [ModelHandler insertLanguages:languages];
}

+(BiblicalModel*)getChaptersList:(NSString*)languageCode
{
    return [ModelHandler fetchBiblicalDataOf:languageCode];

}
@end
