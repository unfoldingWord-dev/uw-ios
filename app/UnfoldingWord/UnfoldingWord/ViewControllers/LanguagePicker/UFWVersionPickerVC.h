//
//  UFWLanguagePickerVC.h
//  UnfoldingWord
//
//  Created by David Solberg on 5/7/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
@class UWTOC;
@class UWVersion;
@class UWTopContainer;

typedef void (^VersionPickerCompletion) (BOOL isCanceled, UWVersion * __nullable versionPicked, MediaType mediaToShow);

@interface UFWVersionPickerVC : UITableViewController

+ (UIViewController * __nonnull)navigationLanguagePickerWithTOC:(UWTOC * __nullable)toc topContainer:(UWTopContainer * __nonnull)topContainer completion:(VersionPickerCompletion __nonnull)completion;

@end
