//
//  NSArray+Helpers.swift
//  UnfoldingWord
//
//  Created by David Solberg on 11/19/15.
//  Copyright © 2015 Acts Media Inc. All rights reserved.
//

import Foundation

extension Array where Element : Equatable {
    
    func anyItemEqualToItem(item : Element) -> Element? {
        guard self.count > 0 else {
             return nil
        }
        let results = self.filter({ $0 == item })
        return results.first
    }
}

protocol StringFindSubStrings {
    func containsSubString(string: String) -> Bool
    func startsWithString(string: String) -> Bool
    func endsWithString(string: String) -> Bool
}

extension String : StringFindSubStrings {
    func containsSubString(string: String) -> Bool {
        return (self as NSString).rangeOfString(string).location != NSNotFound
    }
    
    func startsWithString(string: String) -> Bool {
        let range = (self as NSString).rangeOfString(string)
        if range.location == NSNotFound {
            return false
        }
        else {
            return range.location == 0
        }
    }
    
    func endsWithString(string: String) -> Bool {
        let range = (self as NSString).rangeOfString(string)
        if range.location == NSNotFound {
            return false
        }
        else {
            let length = self.characters.count
            let startIndex = length - range.length
            return startIndex == range.location
        }
    }
}

extension Array where Element : StringFindSubStrings {
    
    func allItemsThatStartWithString(start : String, andEndWithString end : String) -> [Element]? {
        let results = self.filter { $0.startsWithString(start) && $0.endsWithString(end) }
        return results
    }
    
    func allItemsThatContainSubString(string : String) -> [Element]? {
        let results = self.filter({ $0.containsSubString(string) })
        return results
    }
    
    func allItemsThatContainSubStrings(substrings : [String]) -> [Element]? {
        let results = self.filter { (originalArrayString) -> Bool in
            let filtered = substrings.filter({ return originalArrayString.containsSubString($0) })
            return substrings.count == filtered.count
        }
        return results
    }
    
}