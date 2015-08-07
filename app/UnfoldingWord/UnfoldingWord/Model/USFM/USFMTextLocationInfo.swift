//
//  USFMTextLocationInfo.swift
//  UnfoldingWord
//
//  Created by David Solberg on 7/30/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

import Foundation

@objc class USFMTextLocationInfo : NSObject {
    var textRange : NSRange
    var indexChapter : NSInteger
    
    init(range : NSRange , index : NSInteger) {
        self.textRange = range
        self.indexChapter = index
    }
}