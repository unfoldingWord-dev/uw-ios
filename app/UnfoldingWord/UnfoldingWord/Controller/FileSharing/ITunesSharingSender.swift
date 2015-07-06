//
//  ITunesSharingSender.swift
//  UnfoldingWord
//
//  Created by David Solberg on 7/5/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

import Foundation

@objc final class ITunesSharingSender : NSObject {
    
    let version : UWVersion
    
    init (version : UWVersion) {
        self.version = version
        super.init()
    }
    
    func sendToITunesFolder() -> Bool {
        let exporter = UFWFileExporter(version: self.version)
        if let data = exporter.fileData {
            let savePath = NSString.appDocumentsDirectory().stringByAppendingPathComponent(self.version.filename())
            if NSFileManager.defaultManager().createFileAtPath(savePath, contents: data, attributes: nil) {
                ITunesSharingReceiver().addExistingFilePath(savePath)
                return true
            }
        }
        return false
    }

}