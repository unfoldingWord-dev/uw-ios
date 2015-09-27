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

typedef void (^ChapterPickerCompletion) (BOOL isCanceled, OpenChapter * __nullable  selectedChapter);

@interface ChapterListTableViewController : UITableViewController

+ (UIViewController * __nonnull)navigationChapterPickerCompletion:(ChapterPickerCompletion __nonnull)completion;

@end
