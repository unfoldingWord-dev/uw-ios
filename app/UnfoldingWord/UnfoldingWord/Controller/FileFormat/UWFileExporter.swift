//
//  UFWFileExporter.swift
//  UnfoldingWord
//
//  Created by David Solberg on 6/16/15.
//

import Foundation
import CoreData

@objc final class UFWFileExporter : NSObject {
    
    let sourceVersion : UWVersion
    
    init(version : UWVersion) {
        self.sourceVersion = version
    }
    
    /// The file is a json string converted to data. The enclosed json is a dictionary with 1. a toplevel dictionary with the exported language and version, and 2. a sources dictionary that contains the necessary contents to populate based on the urls in the version's TOC items.
    var fileData : NSData? {
        get {
            let top = createTopContainerFullDictionary()
            let sources = createUrlSources()
            let fileDict = NSDictionary(objects: [top, sources], forKeys: [Constants.FileFormat.TopLevel, Constants.FileFormat.SourcesArray])
            let file = UFWFile(sourceDictionary: fileDict)
            if file.isValid {
                return file.fileData
            }
            else {
                assertionFailure("File was invalid based on dictionary \(fileDict)")
                return nil
            }
        }
    }
    
    /// Creates a JSON representation that would exist if we had just one top level object with one language and one version. Of course, this requires that importing does not delete objects that already exist
    private func createTopContainerFullDictionary() -> NSDictionary {
        var topDic = sourceVersion.language.topContainer.jsonRepresentionWithoutLanguages()
        var languageDic = sourceVersion.language.jsonRepresentionWithoutVersions()
        let versionDic = sourceVersion.jsonRepresention()
        
        languageDic[Constants.JSONName.Versions] = [versionDic]
        topDic[Constants.JSONName.Languages] = [languageDic]
        
        return topDic
    }
    
    /// Each toc item has two things retrieved from urls: its file contents and its signature. Each item is keyed to a url in the return dictionary. For example, if we have five TOC's, then we would expect 10 items in the dictionary (2 for each TOC).
    private func createUrlSources() -> NSDictionary {
        var sources = NSMutableDictionary()
        
        for tocItem in sourceVersion.sortedTOCs() {
            let toc = tocItem as! UWTOC
            let tocContents = contents(toc)
            
            if let
                fileString = tocContents.fileContents,
                url = toc.src
            {
                sources.setValue(fileString, forKey: url)
            } else {
                println("The toc \(toc.title) is missing information for its file contents.")
            }
            
            if let
                signature = tocContents.signatureContents,
                url = toc.src_sig
            {
                sources.setValue(signature, forKey: url)

            } else {
                println("The toc \(toc.title) is missing information for its signature")
            }
        }
        return sources
    }
    
    /// Returns the saved file contents of the toc
    private func contents(toc : UWTOC) -> (fileContents: NSString?, signatureContents: NSString?) {
        if let usfm = toc.usfmInfo {
            let contents : NSString? = fileContents(usfm.filename)
            let sig : NSString? = fileContents(usfm.filename, fileExtension: Constants.SignatureFileAppend)
            return (contents, sig)
        } else if let open = toc.openContainer {
            let contents : NSString? = fileContents(open.filename)
            let sig : NSString? = fileContents(open.filename, fileExtension: Constants.SignatureFileAppend)
            return (contents, sig)
        } else {
            return(nil, nil)
        }
    }
    
    // Helpers
    private func fileContents(filename : NSString) -> NSString? {
        let path = NSString.documentsDirectory().stringByAppendingPathComponent(filename as String)
        let string = NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding, error: nil)
        return string
    }
    
    private func fileContents(filename : NSString, fileExtension : NSString) -> NSString? {
        let revisedFilename = filename.stringByAppendingString(fileExtension as String)
        return fileContents(revisedFilename)
    }
    
}