//
//  USFMTextLocationInfo.swift
//  UnfoldingWord
//
//  Created by David Solberg on 7/30/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

import Foundation

/// This class tracks the current offsets so we can reset the visible text after, for example, a rotation.
@objc class USFMTextLocationInfo : NSObject {
    @objc var textRange : NSRange
    @objc var indexChapter : NSInteger
    
    @objc init(range : NSRange , index : NSInteger) {
        self.textRange = range
        self.indexChapter = index
    }
}
