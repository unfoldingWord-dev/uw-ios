//
//  UFWLanguagePickerVC.h
//  UnfoldingWord
//
//  Created by David Solberg on 5/7/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UWTopContainer;
@class UWVersion;

typedef void (^LanguagePickerCompletion) (BOOL isCanceled, UWVersion *versionPicked);

@interface UFWLanguagePickerVC : UITableViewController

@property (nonatomic, strong) UWTopContainer *topContainer;

+ (UIViewController *)navigationLanguagePickerWithTopContainer:(UWTopContainer *)topContainer isSide:(BOOL)isSide completion:(LanguagePickerCompletion)completion;

@end
