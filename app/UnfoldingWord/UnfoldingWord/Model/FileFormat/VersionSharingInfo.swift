//
//  VersionSharingInfo.swift
//  UnfoldingWord
//
//  Created by David Solberg on 12/10/15.
//  Copyright © 2015 Acts Media Inc. All rights reserved.
//

import Foundation

@objc class VersionQueue : NSObject {
    private var arrayVersionSharing : [VersionSharingInfo]
    
    init(sharingInfo: [VersionSharingInfo]) {
        arrayVersionSharing = sharingInfo
    }
    
    convenience init(version: UWVersion, options: DownloadOptions)
    {
        let sharing = VersionSharingInfo(version: version, options: options)
        self.init(sharingInfo: [sharing])
    }
    
    var count : Int {  return arrayVersionSharing.count }
    
    func popVersionSharingInfo() -> VersionSharingInfo? {
        return arrayVersionSharing.popLast()
    }
}

@objc class LanguageSharingInfo : NSObject {
    var isExpanded = false
    let language: UWLanguage
    let arrayVersionSharingInfo : [VersionSharingInfo]
    
    init(language: UWLanguage, sharingArray: [VersionSharingInfo]) {
        self.language = language
        self.arrayVersionSharingInfo = sharingArray
    }
    
    static func createVersionQueue(arrayOfArrays: [[LanguageSharingInfo]]) -> VersionQueue {
        let versionSharing = arrayOfArrays.flatMap {$0}.flatMap { (languageInfo) -> [VersionSharingInfo] in
            languageInfo.arrayVersionSharingInfo.flatMap({ (versionInfo) -> [VersionSharingInfo] in
                return versionInfo.hasContent ? [versionInfo] : [VersionSharingInfo]()
            })
        }
        return VersionQueue(sharingInfo: versionSharing)
    }
}

@objc class VersionSharingInfo : NSObject {
    let version: UWVersion
    var options: DownloadOptions
    
    init(version: UWVersion, options: DownloadOptions) {
        self.version = version
        self.options = options
    }
    
    var hasContent : Bool {
        if options.contains(.Audio) || options.contains(.Text) || options.contains(.Video) {
            return true
        }
        return false
    }
    
    func fileSource() -> NSURL?
    {
        let exporter = UFWFileExporter(version: version, options: options)
        if let successPath = exporter.fileDataPath {
            return NSURL(fileURLWithPath: successPath)
        } else {
            return nil
        }
    }

}

