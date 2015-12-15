//
//  UFWFileActivityItemProvider.swift
//  UnfoldingWord
//
//  Created by David Solberg on 7/9/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

import Foundation

/// This is an item provider. It's only purpose to to allow the app not to need to assemble a whole version into a file before we know for sure that the user will really want to send it. The activity view controller already takes too long to show up, but this hopefully helps a little.
final class UFWFileActivityItemProvider : UIActivityItemProvider {
    
    let queue : VersionQueue

    init(placeholderItem: AnyObject, queue : VersionQueue) {
        self.queue = queue
        super.init(placeholderItem: placeholderItem)
    }
    
    override func item() -> AnyObject {
        return queue;
    }

}