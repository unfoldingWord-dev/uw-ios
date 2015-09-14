//
//  UFWBookPickerUSFMVC.h
//  UnfoldingWord
//
//  Created by David Solberg on 5/12/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UWTOC, UWVersion;

typedef void (^BookPickerCompletion) (BOOL isCanceled, UWTOC* __nullable tocPicked, NSInteger chapterPicked);

@interface UFWBookPickerUSFMVC : UITableViewController

+ (UIViewController * __nonnull)navigationBookPickerWithVersion:(UWVersion * __nonnull)version completion:(BookPickerCompletion __nonnull)completion;

@end
