//
//  VerseContainer.h
//  UnfoldingWord
//
//  Created by David Solberg on 7/22/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef UnfoldingWord_VerseContainer_h
#define UnfoldingWord_VerseContainer_h
#endif

/// A struct to hold USFM verse information. This is used on the diglot (side-by-side) views to sync both sides to the same verse.
struct VerseContainer {
    
    /// The minimum verse number currently visible in the textview.
    NSInteger min;
    
    /// The enclosing rect of the verse relative to the textview's current scroll point. For example, a rect of {5, -50, 230, 125} would indicate that 50 points are hidden above the current scrollpoint, and 75 points are actually visible (125 + -150).
    CGRect minRectRelativeToScreenPosition;
    
    /// If the minimum verse is actually at the very start of the textview. (Scrolled all the way up.)
    BOOL minIsAtStart;
    
    /// The maximum verse number currently visible in the textview.
    NSInteger max;
    
    /// The enclosing rect of the verse relative to the textview's current scroll point. For example, a rect of {5, -50, 230, 125} would indicate that 50 points are hidden above the current scrollpoint, and 75 points are actually visible (125 + -150).
    CGRect maxRectRelativeToScreenPosition;
    
    /// If the maximum verse is at the very end of the textview. (Scrolled all the way down.)
    BOOL maxIsAtEnd;
    
    /// The height of a row of text.
    CGFloat rowHeight;
};
typedef struct VerseContainer VerseContainer;
