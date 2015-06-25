//
//  UFWFile.swift
//  UnfoldingWord
//
//  Created by David Solberg on 6/15/15.
//

import UIKit


@objc final class UFWFile {

    let sourceDictionary: NSDictionary
    let isValid : Bool
    
    /// Returns the data containing the JSON string that represents all the data needed to create teh 
    var fileData : NSData {
        get {
            var error : NSError?
            if let data = NSJSONSerialization.dataWithJSONObject(sourceDictionary, options: nil, error: &error) {
                return data
            }
            assertionFailure("Could not create data from dictionary \(sourceDictionary) \n\n error: \(error)")
            return NSData()
        }
    }
    
    /// Returns the top level object used to populate the database with the enclosed file
    var topLevelObject : NSDictionary {
        get {
            if let dictionary = self.sourceDictionary[Constants.FileFormat.TopLevel] as? NSDictionary {
                return dictionary;
            }
            assertionFailure("Could not create dictionary for key \(Constants.FileFormat.TopLevel) from \(self.sourceDictionary)")
            return NSDictionary()
        }
    }
    
    /// Returns a source item to populate each toc item with content and signature json
    func sourceItemForUrl(url: NSString) -> UrlSourceItem? {
        if let
            sources = self.sourceDictionary[Constants.FileFormat.SourcesArray] as? NSDictionary,
            sourceContent = sources.valueForKey(url as String) as? NSString
            {
                return UrlSourceItem(url: url, content: sourceContent)
            }
        else {
            assertionFailure("Could not create sources for url \(url)")
            return nil
        }
    }
    
    init(sourceDictionary : NSDictionary) {
        self.isValid = UFWFile.validateSource(sourceDictionary)
        self.sourceDictionary = sourceDictionary
    }
    
    init(fileData : NSData) {
        var dictionary: NSDictionary?
        var error : NSError?
        if let data = NSJSONSerialization.JSONObjectWithData(fileData, options: NSJSONReadingOptions.AllowFragments, error: &error) as? NSDictionary {
            dictionary = data
        }
        
        switch (dictionary) {
        case .None:
            self.sourceDictionary = NSDictionary()
            self.isValid = false
            assertionFailure("Could not create dictionary from data \(fileData) \n\n error: \(error)")
        case .Some:
            self.sourceDictionary = dictionary!
            self.isValid = true

        }
    }
    
    class func validateSource(source : NSDictionary?) -> Bool {
        if let
            source = source,
            top_level = source[Constants.FileFormat.TopLevel] as? NSDictionary,
            sourceArray = source[Constants.FileFormat.SourcesArray] as? NSDictionary
        {
            return true
        }
        else {
            assertionFailure("At least one object was missing from the source.")
            return false
        }
    }
}