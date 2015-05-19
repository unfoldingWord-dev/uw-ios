//
//  ChapterListTableViewController.h
//  UnfoldingWord
//
//  Created by Acts Media Inc. on 01/12/14.
//  Copyright (c) 2014 Distant Shores Media All rights reserved.
//

#import <UIKit/UIKit.h>
@class UWTopContainer;
@class OpenChapter;

typedef void (^ChapterPickerCompletion) (BOOL isCanceled, OpenChapter *selectedChapter);

@interface ChapterListTableViewController : UITableViewController

@property (nonatomic, strong) UWTopContainer *topContainer;

+ (UIViewController *)navigationChapterPickerWithTopContainer:(UWTopContainer *)topContainer completion:(ChapterPickerCompletion)completion;

@end
