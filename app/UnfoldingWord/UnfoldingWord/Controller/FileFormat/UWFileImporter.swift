//
//  UFWFileImporter.swift
//  UnfoldingWord
//
//  Created by David Solberg on 6/16/15.
//

import Foundation
import CoreData

@objc final class UFWFileImporter : NSObject {
    
    let file : UFWFile
    
    init(data : NSData) {
        self.file = UFWFile(fileData: data)
    }
    
    /// Imports the version, creating the top level object and language only if necessary. Imports and checks the data and signature for each TOC. Overwrites any existing data.
    func importFile() -> Bool {
        
        if self.file.isValid == false  {
            assertionFailure("Invalid source file: \(self.file)")
            return false
        }
        
        let topDictionary = self.file.topLevelObject
        UWTopContainer.updateFromArray([topDictionary])
        
        if let
            top = UWTopContainer(forDictionary: topDictionary as [NSObject : AnyObject]),
            version = top.versionForDictionary(topDictionary as [NSObject : AnyObject])
        {
            for toc in version.toc {
                if importTOCContents(toc as! UWTOC) == false {
                    assertionFailure("Could not import toc: \(toc)")
                }
            }
            do {
                try DWSCoreDataStack.managedObjectContext().save()
            }
            catch {
                assertionFailure("Could save data!")
            }
        }
        else {
            assertionFailure("Did not successfully create version from dictionary \(topDictionary)")
            return false
        }
        return true
    }
    
    /// This succeeds only if both the signature and the contents are found and successfully imported
    func importTOCContents(toc : UWTOC) -> Bool {
        if let signature = signatureForTOC(toc) {
            let contents = contentsForTOC(toc)
            if let usfm = contents.usfm {
                return toc.importWithUSFM(usfm as String, signature: signature as String)
            }
            else if let openBible = contents.openJSON {
                return toc.importWithOpenBible(openBible as String, signature: signature as String)
            }
        }
        return false
    }
    
    /// Retrieves the raw string for the signature JSON
    func signatureForTOC(toc : UWTOC) -> NSString? {
        if let signatureItem = file.sourceItemForUrl(toc.src_sig) {
            switch (signatureItem.type) {
            case let .Signature(sig):
                return sig
            default:
                break
            }
        }
        return nil
    }
    
    /// Retrieves the raw string for either the usfm or the open bible stories JSON
    func contentsForTOC(toc : UWTOC) -> (usfm : NSString?, openJSON : NSString?) {
        
        var usfm : NSString? = nil
        var openJSON : NSString? = nil
        if let sourceItem = file.sourceItemForUrl(toc.src) {
            switch (sourceItem.type) {
            case let UrlContentType.OpenBibleStories(open):
                openJSON = open
            case let UrlContentType.USFM(usfmString):
                usfm = usfmString
            default:
                break
            }
        }
        return (usfm, openJSON)
    }
    
    /// Find out whether importing the file will overwrite existing an existing version's data
    func willOverwrite() -> Bool {
        let topDictionary = self.file.topLevelObject
        if let
            top = UWTopContainer(forDictionary: topDictionary as [NSObject : AnyObject]),
            _ = top.versionForDictionary(topDictionary as [NSObject : AnyObject])
        {
            return true
        }
        return false
    }
    
}