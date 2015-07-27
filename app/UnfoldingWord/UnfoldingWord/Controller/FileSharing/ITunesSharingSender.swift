//
//  ITunesSharingSender.swift
//  UnfoldingWord
//
//  Created by David Solberg on 7/5/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

import Foundation

@objc final class ITunesSharingSender : NSObject {
    
    func sendToITunesFolder(data : NSData?, filename : String?) -> Bool {
        if let data = data, filename = filename {
            let savePath = NSString.appDocumentsDirectory().stringByAppendingPathComponent(filename)
            if NSFileManager.defaultManager().createFileAtPath(savePath, contents: data, attributes: nil) {
                ITunesSharingReceiver().addExistingFilePath(savePath)
                return true
            }
        }
        return false
    }

}