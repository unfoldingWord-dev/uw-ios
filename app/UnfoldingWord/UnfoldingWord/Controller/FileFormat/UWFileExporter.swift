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
    var fileData : Data? {
        get {
            let top = createTopContainerFullDictionary()
            let sources = createUrlSources()
            let fileDict = NSMutableDictionary()
            fileDict[Constants.FileFormat.TopLevel] = top
            fileDict[Constants.FileFormat.SourcesArray] = sources

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
        var topDic: [AnyHashable: Any] = sourceVersion.language.topContainer.jsonRepresentionWithoutLanguages()
        var languageDic: [AnyHashable: Any] = sourceVersion.language.jsonRepresentionWithoutVersions()
        let versionDic: [AnyHashable: Any] = sourceVersion.jsonRepresention()

        languageDic[Constants.JSONName.Versions] = [versionDic]
        topDic[Constants.JSONName.Languages] = [languageDic]
        
        return topDic as NSDictionary
    }
    
    /// Each toc item has two things retrieved from urls: its file contents and its signature. Each item is keyed to a url in the return dictionary. For example, if we have five TOC's, then we would expect 10 items in the dictionary (2 for each TOC).
    private func createUrlSources() -> NSDictionary {
        var sources = [AnyHashable: Any]()
        
        for tocItem in sourceVersion.sortedTOCs() {
            let toc = tocItem as! UWTOC
            let tocContents = contents(toc: toc)
            
            if let fileString = tocContents.fileContents,
               let url = toc.src
            {
                sources[url] = fileString
            } else {
                print("The toc \(String(describing: toc.title)) is missing information for its file contents.")
            }
            
            if let signature = tocContents.signatureContents,
               let url = toc.src_sig
            {
                sources[url] = signature

            } else {
                print("The toc \(String(describing: toc.title)) is missing information for its signature")
            }
        }
        return sources as NSDictionary
    }
    
    /// Returns the saved file contents of the toc
    private func contents(toc : UWTOC) -> (fileContents: NSString?, signatureContents: NSString?) {
        if let usfm = toc.usfmInfo,
            let contents = fileContents(usfm.filename),
            let sig = fileContents(usfm.filename, fileExtension: Constants.SignatureFileAppend)
        {
            return (fileContents: contents, signatureContents: sig)
        } else if let open = toc.openContainer,
            let contents  = fileContents(open.filename),
            let sig  = fileContents(open.filename, fileExtension: Constants.SignatureFileAppend)
        {
            return (fileContents: contents, signatureContents: sig)
        } else {
            return(nil, nil)
        }
    }
    
    // Helpers
    private func fileContents(_ filename: String) -> NSString? {
        let path = (NSString.documentsDirectory() as NSString).appendingPathComponent(filename)
        let string = try? NSString(contentsOfFile: path, encoding: String.Encoding.utf8.rawValue)
        return string
    }
    
    private func fileContents(_ filename: String, fileExtension: String) -> NSString? {
        let revisedFilename = (filename as NSString).appendingPathComponent(fileExtension)
        return fileContents(revisedFilename)
    }
    
}
