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
@class UWTopContainer;

typedef void (^VersionPickerCompletion) (BOOL isCanceled, UWVersion * __nullable versionPicked);

@interface UFWVersionPickerVC : UITableViewController

+ (UIViewController * __nonnull)navigationLanguagePickerWithTOC:(UWTOC * __nullable)toc topContainer:(UWTopContainer * __nonnull)topContainer completion:(VersionPickerCompletion __nonnull)completion;

@end
