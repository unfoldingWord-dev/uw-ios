//
//  UFWFileImporter.swift
//  UnfoldingWord
//
//  Created by David Solberg on 6/16/15.
//

import Foundation
import CoreData

@objc final class UFWFileImporter : NSObject {
    
    /// Imports the version, creating the top level object and language only if necessary. Imports and checks the data and signature for each TOC. Overwrites any existing data.
    func importData(data : NSData?) -> Bool {
        guard let data = data else {return false}
        let path = String.temporaryFilePathInCacheDirectory()
        guard data.writeToFile(path, atomically: true) else { return false }
        let result = importZipFileData(withPath: path)
        path.deleteFileOrFolder()
        return result
    }
    
    func importZipFileData(withPath inputPath : String) -> Bool {
        
        guard
            let directory = inputPath.unzippedDataFromPathToPath(),
            let filenames = try? NSFileManager.defaultManager().contentsOfDirectoryAtPath(directory),
            jsonPath = jsonFilePathFromNames(filenames: filenames, inDirectory: directory)
        else { return false }

        guard importJSONFileAtPath(jsonPath) == true else { return false }
        importAudioFiles(filenames, directory: directory)
        return true
    }
    
    // MARK: - Importing Any Audio
    func importAudioFiles(filenames : [String], directory : String) -> Int {
        
        guard let
            audioFiles = filenames.allItemsThatStartWithString(FileNamer.filePrefixAudio, andEndWithString: FileNamer.fileSuffixAudio),
            audioSigFiles = filenames.allItemsThatStartWithString(FileNamer.filePrefixAudio, andEndWithString: FileNamer.fileSuffixSignature)
        else { return 0 }
        
         var count  = 0
        
        audioFiles.forEach { (audioFileName) -> () in
            guard let
                bitrate = FileNamer.audioBitrateForName(audioFileName)  else {
                print("No matching bitrate for audio file \(audioFileName)")
                return
            }
            
            let audioPath = directory.stringByAppendingPathComponent(audioFileName)
            let audioSigFileName = FileNamer.signatureFileFromAudioFile(audioFileName)
            let audioSigPath = directory.stringByAppendingPathComponent(audioSigFileName)
            
            guard NSFileManager.defaultManager().fileExistsAtPath(audioPath) else {
                assertionFailure("What? Nothing at path \(audioPath)")
                return
            }
            
            var isValid = false
            if NSFileManager.defaultManager().fileExistsAtPath(audioSigPath) && audioSigFiles.contains(audioSigFileName) {
                isValid = UWDownloaderPlusValidator.validateSourcePath(audioPath, usingSignaturePath: audioSigPath)
            }
            else {
                isValid = false
                print("No signature at path \(audioSigPath). \n\n List of signatures: \(audioSigFiles)")
            }
            bitrate.saveAudioAtPath(audioPath, withSignatureAtPath: audioSigPath, isValid: isValid)

            count++
        }
        
        return count
    }
    
    
    // MARK: - Importing Text from JSON
    func jsonFilePathFromNames(filenames filenameArray : [String], inDirectory directory : String) -> String? {
        var jsonTextFilename : String? = nil
        for name in filenameArray {
            if (name as NSString).rangeOfString(FileNamer.filePrefixJSONText).location != NSNotFound {
                jsonTextFilename = name
                break
            }
        }
        
        guard let jsonFileName = jsonTextFilename else {
            assertionFailure("Could not find a json file in unzipped files: \(filenameArray)")
            return nil
        }
        
        return (directory as NSString).stringByAppendingPathComponent(jsonFileName)
    }
    
    
    func importJSONFileAtPath(jsonFilePath : String) -> Bool {
        guard
            let data = NSData(contentsOfFile: jsonFilePath),
            let file = UFWFileText(fileData:data) where file.isValid
            else {
                assertionFailure("Invalid source file: \(jsonFilePath)")
                return false
        }
        
        let topDictionary = file.topLevelObject
        UWTopContainer.updateFromArray([topDictionary])
        
        if let
            top = UWTopContainer(forDictionary: topDictionary as [NSObject : AnyObject]),
            version = top.versionForDictionary(topDictionary as [NSObject : AnyObject])
        {
            for toc in version.toc {
                if importTOCContents(toc, jsonTextFile: file) == false {
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
    func importTOCContents(toc : UWTOC, jsonTextFile file: UFWFileText) -> Bool {
        if let signature = signatureForTOC(toc, jsonTextFile: file) {
            let contents = contentsForTOC(toc, jsonTextFile: file)
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
    func signatureForTOC(toc : UWTOC, jsonTextFile file: UFWFileText) -> NSString? {
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
    func contentsForTOC(toc : UWTOC, jsonTextFile file: UFWFileText) -> (usfm : NSString?, openJSON : NSString?) {
        
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
    func willOverwrite(usingJSONTextFile file: UFWFileText) -> Bool {
        let topDictionary = file.topLevelObject
        if let
            top = UWTopContainer(forDictionary: topDictionary as [NSObject : AnyObject]),
            _ = top.versionForDictionary(topDictionary as [NSObject : AnyObject])
        {
            return true
        }
        return false
    }
    
}