//
//  Copyright (c) 2013 Acts Media. All rights reserved.
//

#import "UFWBible.h"
#import "DWSCoreDataStack.h"
#import "UFWLanguage.h"
#import "NSDictionary+DWSNull.h"
#import "CoreDataClasses.h"

static NSString *const kAppWordsFolder = @"app_words";
static NSString *const kChaptersString = @"chapters";
static NSString *const kLanguagesString = @"languages";
static NSString *const kNextChapterString = @"next_chapter";
static NSString *const kChaptersFolder = @"chapters";


@implementation UFWBible
{
    UFWChapter *_savedChapter;
    UFWFrame *_savedFrame;
}

+ (void)createOrUpdateBibleWithDictionary:(NSDictionary *)dictionary forLanguage:(UFWLanguage *)language
{
    UFWBible *bible = language.bible;
    if (bible == nil) {
        bible = [UFWBible insertInManagedObjectContext:[DWSCoreDataStack managedObjectContext]];
        bible.language = language;
    }
    [self updateBible:bible withDictionary:dictionary];
}

+ (void)updateBible:(UFWBible *)bible withDictionary:(NSDictionary *)dictionary
{
    NSDictionary *appWordsDictionary = [dictionary objectOrNilForKey:kAppWordsFolder];
    
    bible.chapters_string = [appWordsDictionary objectOrNilForKey:kChaptersString];
    bible.languages_string = [appWordsDictionary objectOrNilForKey:kLanguagesString];
    bible.next_chapter_string = [appWordsDictionary objectOrNilForKey:kNextChapterString];
    
    NSArray *chaptersArray = [dictionary objectOrNilForKey:kChaptersFolder];
    
    for (NSDictionary *chapterDictionary in chaptersArray) {
        [UFWChapter chapterForDictionary:chapterDictionary forBible:bible];
    }
    
    NSError *error;
    [[DWSCoreDataStack managedObjectContext] save:&error];
    NSAssert2( ! error, @"%s: Error saving a language: %@",__PRETTY_FUNCTION__, error);
}


- (NSArray *)sortedChapters
{
    NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"number" ascending:YES]];
    NSArray *sortedArray = [self.chapters sortedArrayUsingDescriptors:sortDescriptors];
    return sortedArray;
}

#pragma mark - Setting Chapters and Frames
- (UFWChapter *)currentChapter;
{
    if (self.current_chapter_number == nil) {
        return nil;
    }
    else if (_savedChapter != nil) {
        return _savedChapter;
    }
    else {
        UFWChapter *chapter = nil;
        for (UFWChapter *candidateChapter in self.chapters) {
            if ([candidateChapter.number isEqualToString:self.current_chapter_number]) {
                chapter = candidateChapter;
                break;
            }
        }
        _savedChapter = chapter;
        return chapter;
    }
}

- (void)setCurrentChapter:(UFWChapter *)chapter;
{
    _savedChapter = chapter;
    
    self.current_chapter_number = chapter.number;
    NSError *error;
    [[DWSCoreDataStack managedObjectContext] save:&error];
    NSAssert2( ! error, @"%s: Error saving core data: %@", __PRETTY_FUNCTION__, error);
}

- (UFWFrame *)currentFrame;
{
    if (self.current_frame_number == nil) {
        return nil;
    }
    else if (_savedFrame != nil) {
        return _savedFrame;
    }
    else {
        UFWFrame *frame = nil;
        for (UFWFrame *candidateFrame in self.currentChapter.frames) {
            if ([candidateFrame.uid isEqualToString:self.current_frame_number]) {
                frame = candidateFrame;
                break;
            }
        }
        _savedFrame = frame;
        return frame;
    }
}

- (void)setCurrentFrame:(UFWFrame *)frame;
{
    _savedFrame = frame;
    
    self.current_frame_number = frame.uid;
    NSError *error;
    [[DWSCoreDataStack managedObjectContext] save:&error];
    NSAssert2( ! error, @"%s: Error saving core data: %@", __PRETTY_FUNCTION__, error);
}


@end
