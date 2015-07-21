//
//  UFWTextChapterVC.h
//  UnfoldingWord
//
//  Created by David Solberg on 5/6/15.
//

#import <UIKit/UIKit.h>

@class UWTopContainer;

@interface UFWTextChapterVC : UIViewController

@property (nonatomic, strong) UWTopContainer *topContainer;
@property (nonatomic, assign) BOOL isSideTOC;

@end
