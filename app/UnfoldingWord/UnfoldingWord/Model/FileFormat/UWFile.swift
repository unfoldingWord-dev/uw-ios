//
//  UFWFile.swift
//  UnfoldingWord
//
//  Created by David Solberg on 6/15/15.
//

import UIKit

@objc final class UFWFile: NSObject {

    let sourceDictionary: NSDictionary
    @objc let isValid : Bool
    
    /// Returns the data containing the JSON string that represents all the data needed to create teh 
    var fileData : Data {
        get {
            do {
                let data = try JSONSerialization.data(withJSONObject: sourceDictionary, options: .fragmentsAllowed)
                if let zipData = (data as NSData).gzippedData(withCompressionLevel: 0.95) {
                    return zipData
                } else {
                    assertionFailure("Could not create  data from dictionary \(sourceDictionary)")
                }
            } catch {
                assertionFailure("Could not create gzip from dictionary \(sourceDictionary) \n\n error: \(error)")
            }
            return Data()
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
    func sourceItemForUrl(url: String) -> UrlSourceItem? {
        if let sources = self.sourceDictionary[Constants.FileFormat.SourcesArray] as? NSDictionary,
           let sourceContent = sources.value(forKey: url) as? String
        {
            return UrlSourceItem(url: url, content: sourceContent)
        } else {
            assertionFailure("Could not create sources for url \(url)")
            return nil
        }
    }
    
    init(sourceDictionary : NSDictionary) {
        self.isValid = UFWFile.validateSource(source: sourceDictionary)
        self.sourceDictionary = sourceDictionary
    }
    
    init(fileData : NSData) {
        if let unzippedData = fileData.gunzipped(),
           let dictionary = try? JSONSerialization.jsonObject(with: unzippedData, options: .allowFragments) as? NSDictionary
        {
            self.sourceDictionary = dictionary
            self.isValid = true
        } else {
            self.sourceDictionary = NSDictionary()
            self.isValid = false
            assertionFailure("Could not create dictionary from gzipped data \(fileData)")
        }
    }
    
    class func validateSource(source : NSDictionary?) -> Bool {
        if let source = source,
           let _ = source[Constants.FileFormat.TopLevel] as? NSDictionary,
           let _ = source[Constants.FileFormat.SourcesArray] as? NSDictionary
        {
            return true
        }
        else {
            assertionFailure("At least one object was missing from the source.")
            return false
        }
    }
}
