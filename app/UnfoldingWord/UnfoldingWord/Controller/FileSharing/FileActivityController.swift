//
//  FileActivityController.swift
//  UnfoldingWord
//
//  Created by David Solberg on 6/22/15.
//

import Foundation
import UIKit

@objc final class FileActivityController: NSObject {
    
    private let version : UWVersion
    private var urlSaved : NSURL?
    
    init(version: UWVersion) {
        self.version = version
        self.urlSaved = nil
    }
    
    private var url : NSURL? {
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
            return nil
        }
    }
    
    func activityViewController() -> UIActivityViewController? {
        if let url = self.url {
            let items = [url]
            let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
            activityVC.excludedActivityTypes = [UIActivityTypePostToWeibo, UIActivityTypePostToFacebook, UIActivityTypePostToTwitter,UIActivityTypeCopyToPasteboard];
            activityVC.setValue("Unfolding Word \(filename())", forKey: "subject")
            return activityVC
        }
        return nil
    }
    
    // Removes the file from storage. Technically, it should get removed relatively soon anyway because it's in the caches folder, but this does it right away.
    func cleanup () {
        if let url = self.urlSaved {
            NSFileManager.defaultManager().removeItemAtURL(url, error: nil)
        }
    }
    
    private func file() -> NSData? {
        let exporter = UFWFileExporter(version: version)
        return exporter.fileData
    }
    
    // Creating User Info
    private func filename() -> String {
        if let
            language = LanguageInfoController.nameForLanguageCode(self.version.language.lc),
            slug = self.version.slug{
                return "\(language) (\(slug))"
        }
        else {
            return "UnfoldingWord file"
        }
    }
    
    private func tempFileURL() -> NSURL? {
        if let completeFilename = filename().stringByAppendingPathExtension(Constants.FileExtensionUFW) {
            let path = NSString.cachesDirectory().stringByAppendingPathComponent(completeFilename)
            return NSURL(fileURLWithPath: path)
        }
        
        return nil
    }
}
