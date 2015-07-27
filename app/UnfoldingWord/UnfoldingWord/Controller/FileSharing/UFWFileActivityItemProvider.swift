//
//  UFWFileActivityItemProvider.swift
//  UnfoldingWord
//
//  Created by David Solberg on 7/9/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

import Foundation

final class UFWFileActivityItemProvider : UIActivityItemProvider {
    
    let version : UWVersion
    private var urlSaved : NSURL?
    
    var url : NSURL! {
        get {
            if let url = self.urlSaved {
                return url
            }
            else if let
                file = file(),
                theUrl = tempFileURL()
            {
                if file.writeToURL(theUrl, atomically: true) {
                    self.urlSaved = theUrl
                    return urlSaved
                }
            }
            assertionFailure("Could not return a url!")
            return nil
        }
    }

    init(placeholderItem: AnyObject, version : UWVersion) {
        self.version = version
        super.init(placeholderItem: placeholderItem)
    }
    
    override func item() -> AnyObject! {
        return url;
    }
    
    // Removes the file from storage. Technically, it should get removed eventually because it's in the caches folder, but this does it right away.
    func cleanup () {
        if let url = self.urlSaved {
            NSFileManager.defaultManager().removeItemAtURL(url, error: nil)
        }
    }
    
    private func file() -> NSData? {
        let exporter = UFWFileExporter(version: version)
        return exporter.fileData
    }
    
    private func tempFileURL() -> NSURL? {
        if let completeFilename = self.version.filename() {
            let path = NSString.cachesDirectory().stringByAppendingPathComponent(completeFilename)
            return NSURL(fileURLWithPath: path)
        }
        return nil
    }
}