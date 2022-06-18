//
//  ITunesSharingSender.swift
//  UnfoldingWord
//
//  Created by David Solberg on 7/5/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

import Foundation

@objc class ITunesSharingSender: NSObject {
    
    @objc func sendToITunesFolder(data: Data?, filename: String?) -> Bool {
        if let data = data, let filename = filename {
            let savePath = (NSString.appDocumentsDirectory() as NSString).appendingPathComponent(filename)
            if FileManager.default.createFile(atPath: savePath, contents: data, attributes: nil) {
                ITunesSharingReceiver().addExistingFilePath(path: savePath)
                return true
            }
        }
        return false
    }
}
