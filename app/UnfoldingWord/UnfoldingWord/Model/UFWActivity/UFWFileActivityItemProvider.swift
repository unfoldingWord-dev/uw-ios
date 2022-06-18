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
    private var urlSaved : URL?
    
    @objc var url : URL! {
        get {
            if let url = self.urlSaved {
                return url
            }
            else if let file = file(),
                let theUrl = tempFileURL()
            {
                do {
                    try file.write(to: theUrl, options: .atomic)
                    self.urlSaved = theUrl
                    return urlSaved
                } catch {
                    print("\(error)")
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

    override var item: Any {
        return url ?? ""
    }
    
    // Removes the file from storage. Technically, it should get removed eventually because it's in the caches folder, but this does it right away.
    func cleanup () {
        if let url = self.urlSaved {
            try? FileManager.default.removeItem(at: url)
        }
    }
    
    private func file() -> Data? {
        let exporter = UFWFileExporter(version: version)
        return exporter.fileData
    }
    
    private func tempFileURL() -> URL? {
        if let completeFilename = self.version.filename() {
            let path = (NSString.cachesDirectory() as NSString).appendingPathComponent(completeFilename)
            return URL(fileURLWithPath: path)
        }
        return nil
    }
}
