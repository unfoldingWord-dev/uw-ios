//
//  ModelHandler.m
//  UnfoldingWord
//
//  Created by Acts Media Inc. on 25/11/14.
//  Copyright (c) 2014 Distant Shores Media All rights reserved.
//

#import "ModelHandler.h"
#import "DWSCoreDataStack.h"
#import "LanguageListModel.h"
#import "LanguageModel.h"
#import "Constants.h"

#import "BiblicalDataModel.h"



#define LANGUAGE_TABLE @"LanguageListModel"
#define BIBLICAL_TABLE @"BiblicalDataModel"

@implementation ModelHandler


+(void)insertLanguages:(NSArray *)languages
{
    [self deleteLanguages];
    NSManagedObjectContext *managedObjectContext = [DWSCoreDataStack managedObjectContext];
    
    for(NSDictionary *language in languages)
    {
        LanguageListModel *newLanguage = (LanguageListModel*)[NSEntityDescription
                                    insertNewObjectForEntityForName:LANGUAGE_TABLE
                                    inManagedObjectContext:managedObjectContext];
        
        
        newLanguage.language_string     = [language valueForKey:k_KEY_LANGUAGE_STRING];
        newLanguage.language            = [language valueForKey:k_KEY_LANGUAGE];
        newLanguage.date_modified       = [language valueForKey:k_KEY_DATE_MODIFIED];
        newLanguage.checking_entity     = [[language valueForKey:@"status"] valueForKey:k_KEY_CHECKING_ENTITY];
        newLanguage.checking_level      = [[language valueForKey:@"status"] valueForKey:k_KEY_CHECHING_LEVEL];
        newLanguage.publish_date        = [[language valueForKey:@"status"] valueForKey:k_KEY_PUBLISH_DATE];
        newLanguage.version             = [[language valueForKey:@"status"] valueForKey:k_KEY_VERSION];
        
        
        NSError *error;
        if (![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }

        
    }
    
    
    
}



+(void)deleteLanguages
{
    NSManagedObjectContext *managedObjectContext = [DWSCoreDataStack managedObjectContext];
    /*
     Fetch existing Languages.
     Create a fetch request for the Language entity; then execute the fetch.
     */
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:LANGUAGE_TABLE];
    [request setFetchBatchSize:20];
    
    // Execute the fetch.
    NSError *error;
    NSArray *fetchResults = [managedObjectContext executeFetchRequest:request error:&error];
    for (NSManagedObject * car in fetchResults) {
        [managedObjectContext deleteObject:car];
    }
    NSError *saveError = nil;
    [managedObjectContext save:&saveError];
}


+(NSMutableArray *)fetchLanguages
{
    
    NSManagedObjectContext *managedObjectContext = [DWSCoreDataStack managedObjectContext];
    /*
     Fetch existing Languages.
     Create a fetch request for the Language entity; then execute the fetch.
     */
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:LANGUAGE_TABLE];
    [request setFetchBatchSize:20];
    
    // Execute the fetch.
    NSError *error;
    NSArray *fetchResults = [managedObjectContext executeFetchRequest:request error:&error];
    if (fetchResults == nil) {
        // Replace this implementation with code to handle the error appropriately.

        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    // Set self's events array to a mutable copy of the fetch results.
    
    NSMutableArray *langResult = [[NSMutableArray alloc] initWithCapacity:[fetchResults count]];
    
    for(LanguageListModel *lModel in fetchResults)
    {
        LanguageModel *langModel = [[LanguageModel alloc] initWithLanguageModel:lModel];
        [langResult addObject:langModel];
    }
    return langResult ;
}






+(void)insertBiblicalData:(NSDictionary *)data LanguageCode:(NSString*)languageCode
{
    
    [self deleteBiblicalData:languageCode];
    NSManagedObjectContext *managedObjectContext = [DWSCoreDataStack managedObjectContext];
    
    {
        BiblicalDataModel *newData = (BiblicalDataModel*)[NSEntityDescription
                                                              insertNewObjectForEntityForName:BIBLICAL_TABLE
                                                              inManagedObjectContext:managedObjectContext];
        
        
        newData.chapters            =  [NSKeyedArchiver archivedDataWithRootObject:[data valueForKey:k_KEY_CHAPTERS]] ;
        newData.language_code       = languageCode;
        newData.chapters_string     = [[data valueForKey:@"app_words"] valueForKey:k_KEY_CHAPTERS];
        newData.next_chapter        = [[data valueForKey:@"app_words"] valueForKey:k_KEY_NEXT_CHAPTER];
        newData.languages_title     = [[data valueForKey:@"app_words"] valueForKey:k_KEY_LANGUAGE_TEXT];
        
        
        NSError *error;
        if (![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        
    }
}


+(void)deleteBiblicalData:(NSString*)languageCode
{
    NSManagedObjectContext *managedObjectContext = [DWSCoreDataStack managedObjectContext];
    /*
     Fetch existing Languages.
     Create a fetch request for the Language entity; then execute the fetch.
     */
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:BIBLICAL_TABLE];
    
//    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO];
//    NSArray *sortDescriptors = @[sortDescriptor];
//    [request setSortDescriptors:sortDescriptors];
    
    NSPredicate *dataBasedOnLanguage = [NSPredicate predicateWithFormat:@"language_code = %@", languageCode];
    [request setPredicate:dataBasedOnLanguage];
    
    // Execute the fetch.
    NSError *error;
    NSArray *fetchResults = [managedObjectContext executeFetchRequest:request error:&error];
    for (NSManagedObject * car in fetchResults) {
        [managedObjectContext deleteObject:car];
    }
    NSError *saveError = nil;
    [managedObjectContext save:&saveError];
}


+(BiblicalModel *)fetchBiblicalDataOf:(NSString*)languageCode
{
    
    NSManagedObjectContext *managedObjectContext = [DWSCoreDataStack managedObjectContext];
    /*
     Fetch existing Languages.
     Create a fetch request for the Language entity; then execute the fetch.
     */
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:BIBLICAL_TABLE];
    NSPredicate *dataBasedOnLanguage = [NSPredicate predicateWithFormat:@"language_code = %@", languageCode];
    [request setPredicate:dataBasedOnLanguage];
    // Execute the fetch.
    NSError *error;
    NSArray *fetchResults = [managedObjectContext executeFetchRequest:request error:&error];
    if (fetchResults == nil) {
        // Replace this implementation with code to handle the error appropriately.
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    // Set self's events array to a mutable copy of the fetch results.

    BiblicalDataModel *bModel =  [fetchResults firstObject];
     BiblicalModel *bibleModel = [[BiblicalModel alloc] initWithDict:bModel];
    return bibleModel ;
}



@end
