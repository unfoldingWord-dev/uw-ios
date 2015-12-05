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
    
    let version : UWVersion
    let options : DownloadOptions
    private var urlSaved : NSURL?
    
    var url : NSURL! {
        get {
            if self.urlSaved == nil {
                if let fileDataPath = filePath() {
                    self.urlSaved = NSURL(fileURLWithPath: fileDataPath)
                }
            }
            return urlSaved
        }
    }

    init(placeholderItem: AnyObject, version : UWVersion, options : DownloadOptions) {
        self.version = version
        self.options = options
        super.init(placeholderItem: placeholderItem)
    }
    
    override func item() -> AnyObject {
        return url;
    }
    
    // Removes the file from storage. Technically, it should get removed eventually because it's in the caches folder, but this does it right away.
    func cleanup () {
        if let url = self.urlSaved {
            do {
                try NSFileManager.defaultManager().removeItemAtURL(url)
            } catch {
                print("Error deleting url \(url)")
            }
        }
    }
    
    private func filePath() -> String? {
        let exporter = UFWFileExporter(version: version, options: options)
        return exporter.fileDataPath
    }
    
    private func tempFileURL() -> NSURL? {
        if let completeFilename = self.version.filename() {
            let path = NSString.cachesDirectory().stringByAppendingPathComponent(completeFilename)
            return NSURL(fileURLWithPath: path)
        }
        return nil
    }
}