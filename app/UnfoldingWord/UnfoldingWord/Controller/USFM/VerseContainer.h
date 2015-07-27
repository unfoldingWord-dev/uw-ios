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
    NSInteger totalCharactersInMinVerse;
    BOOL minIsAtStart;
    NSInteger max;
    BOOL maxIsAtEnd;
    NSInteger charactersInMinVerse;
    NSInteger charactersInMaxVerse;
};
typedef struct VerseContainer VerseContainer;
