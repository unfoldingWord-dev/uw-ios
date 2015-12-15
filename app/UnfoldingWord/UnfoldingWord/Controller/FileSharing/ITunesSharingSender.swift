//
//  ITunesSharingSender.swift
//  UnfoldingWord
//
//  Created by David Solberg on 7/5/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

import Foundation

@objc final class ITunesSharingSender : NSObject {
    
    func sendToITunesFolder(queue : VersionQueue) -> Bool {
        repeat {
            guard let info = queue.popVersionSharingInfo(), fileUrl = info.fileSource() else {  return false }
            
            let basePath = NSString.appDocumentsDirectory() as NSString
            let savePath = basePath.stringByAppendingPathComponent(info.version.filename())
            do {
                try NSFileManager.defaultManager().moveItemAtURL(fileUrl, toURL: NSURL(fileURLWithPath: savePath) )
            } catch (let error) {
                print("\(error)")
            }
            
        } while queue.count > 0
        
        return true
    }
    
}