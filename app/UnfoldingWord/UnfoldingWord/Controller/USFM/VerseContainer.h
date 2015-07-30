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

struct VerseContainer {
    NSInteger min;
    
    CGRect minRectRelativeToScreenPosition;
    BOOL minIsAtStart;
    
    NSInteger max;
    CGRect maxRectRelativeToScreenPosition;
    BOOL maxIsAtEnd;
    
    CGFloat rowHeight;
};
typedef struct VerseContainer VerseContainer;
