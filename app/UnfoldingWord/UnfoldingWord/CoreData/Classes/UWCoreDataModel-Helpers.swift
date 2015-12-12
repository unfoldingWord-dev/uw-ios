//
//  UWVersion-Helpers.swift
//  UnfoldingWord
//
//  Created by David Solberg on 12/11/15.
//  Copyright © 2015 Acts Media Inc. All rights reserved.
//

import Foundation

extension UWVersion {
    
    func downloadedMediaTypes() -> [MediaType]?
    {
        guard self.statusText().contains(.All) else { return nil }
        
        let hasAudio = self.statusAudio().contains(.All)
        let hasVideo = self.statusVideo().contains(.All)
        
        switch (hasAudio, hasVideo) {
        case (true, true):
            return [.Text, .Audio, .Video]
        case (true, false):
            return [.Text, .Audio]
        case (false, true):
            return [.Text, .Video]
        case (false, false):
            return [.Text]
        }
    }
}

extension UWLanguage {
    
    func versionsWithDownloadedContent() -> [UWVersion]? {
        
        let versions = self.versionsSet().allObjects as! [UWVersion]
        let selected = versions.filter { (version) -> Bool in
            if let types = version.downloadedMediaTypes() where types.count > 0 {
                return true
            }
            else {
                return false
            }
        }
        if selected.count > 0 {
            return selected
        }
        else {
            return nil
        }
    }
    
    func sharingInfo() -> LanguageSharingInfo? {
        guard let downloaded = versionsWithDownloadedContent() where downloaded.count > 0
            else { return nil }
        
        let sharingInfo = downloaded.map { (version) -> VersionSharingInfo in
            return VersionSharingInfo(version: version, options: DownloadOptions.Empty)
        }
        return LanguageSharingInfo(language: self, sharingArray: sharingInfo)
        
    }
}

extension UWTopContainer {
    
    func sharingInfoArray() -> [LanguageSharingInfo]
    {
        var results = [LanguageSharingInfo]()
        sortedLanguages.forEach({ (language) -> () in
            let info = language.sharingInfo()
            if let info = info {
                results.append(info)
            }
        })
        return results
    }
    
    static func sortedLanguagedSharingInfoForDownloadedItems() -> [[LanguageSharingInfo]] {
        let containers = self.sortedContainers()
        var results = [[LanguageSharingInfo]]()
        containers.forEach { (container) -> () in
            let infoArray = container.sharingInfoArray()
            if infoArray.count > 0 {
                results.append(infoArray)
            }
        }
        return results
        
    }
}