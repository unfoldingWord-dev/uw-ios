//
//  VersionSharingInfo.swift
//  UnfoldingWord
//
//  Created by David Solberg on 12/10/15.
//  Copyright © 2015 Acts Media Inc. All rights reserved.
//

import Foundation

@objc class LanguageSharingInfo : NSObject {
    var isExpanded = false
    let language: UWLanguage
    let arrayVersionSharingInfo : [VersionSharingInfo]
    
    init(language: UWLanguage, sharingArray: [VersionSharingInfo]) {
        self.language = language
        self.arrayVersionSharingInfo = sharingArray
    }
}

@objc class VersionSharingInfo : NSObject {
    let version: UWVersion
    var options: DownloadOptions
    
    init(version: UWVersion, options: DownloadOptions) {
        self.version = version
        self.options = options
    }
}
