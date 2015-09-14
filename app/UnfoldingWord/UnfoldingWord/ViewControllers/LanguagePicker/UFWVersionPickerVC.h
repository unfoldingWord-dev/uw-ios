//
//  UFWLanguagePickerVC.h
//  UnfoldingWord
//
//  Created by David Solberg on 5/7/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UWTOC;
@class UWVersion;

typedef void (^VersionPickerCompletion) (BOOL isCanceled, UWVersion * __nullable versionPicked);

@interface UFWVersionPickerVC : UITableViewController

+ (UIViewController * __nonnull)navigationLanguagePickerWithTOC:(UWTOC * __nonnull)toc completion:(VersionPickerCompletion __nonnull)completion;

@end
