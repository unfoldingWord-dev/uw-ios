//
//  String+Helpers.swift
//  UnfoldingWord
//
//  Created by David Solberg on 11/20/15.
//  Copyright © 2015 Acts Media Inc. All rights reserved.
//

import Foundation

extension String {
    
    // The actual class name in NSStringFromClass() is the text after the period. Before that is the module name.
    func textAfterLastPeriod() -> String {
        let components = self.componentsSeparatedByString(".")
        return components.last!
    }
    
    func deleteFileOrFolder() -> Bool {
        do {
            try NSFileManager.defaultManager().removeItemAtPath(self)
            return true
        }
        catch {
            assertionFailure("Could not delete files at path \(self)")
            return false
        }
    }
    
    func stringByRemovingSubstringAtStart(string: String) -> String?
    {
        let range = (self as NSString).rangeOfString(string)
        guard range.location != NSNotFound && range.location == 0 else { return nil }
        return (self as NSString).stringByReplacingCharactersInRange(range, withString: "")
    }
    
    func stringByRemovingSubstringAtEnd(string: String) -> String?
    {
        let range = (self as NSString).rangeOfString(string)
        guard range.location != NSNotFound else { return nil }
        
        let length = self.characters.count
        let startIndex = length - range.length
        guard startIndex == range.location else { return nil }
        
        return (self as NSString).stringByReplacingCharactersInRange(range, withString: "")
    }
    
    static func temporaryFilePathInCacheDirectory() -> String {
        
        return cacheDirectory().stringByAppendingPathComponent(unique())
    }
    
    static func cacheDirectory() -> String {
        let cacheDirectories = NSSearchPathForDirectoriesInDomains(
            NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true);
        return cacheDirectories[0]
    }
    
    func pathInCacheDirectory() -> String {
        return (String.cacheDirectory() as NSString).stringByAppendingPathComponent(self)
    }
    
    static func documentsDirectory() -> String {
        let cacheDirectories = NSSearchPathForDirectoriesInDomains(
            NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true);
        return cacheDirectories[0]
    }
    
    static func unique() -> String
    {
        return NSUUID().UUIDString
    }
}