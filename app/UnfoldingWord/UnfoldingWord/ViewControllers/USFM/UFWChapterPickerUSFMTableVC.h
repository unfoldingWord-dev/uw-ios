//
//  UFWChapterPickerUSFMTableVC.h
//  UnfoldingWord
//
//  Created by David Solberg on 5/13/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UFWBookPickerUSFMVC.h"

@class UWTOC;

@interface UFWChapterPickerUSFMTableVC : UITableViewController

@property (nonatomic, copy) BookPickerCompletion completion;
@property (nonatomic, strong) UWTOC *toc;

@end
