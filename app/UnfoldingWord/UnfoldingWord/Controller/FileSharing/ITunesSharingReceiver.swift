//
//  ITunesSharingReceiver.swift
//  UnfoldingWord
//
//  Created by David Solberg on 7/5/15.
//

import Foundation

@objc final class ITunesSharingReceiver : NSObject {
    
    // This is a list of previously imported or created files that we don't want to include in the import list.
    var arrayExistingFileNames : Array<String>!
    
    override init() {
        super.init()
        self.arrayExistingFileNames = retrieveExistingSavedFiles() as! Array<String>
    }
    
    deinit {
        removeDeletedFilesFromExistingFileList()
    }
    
    func filesToDisplayForImport() -> Array<NSString> {
        let filesInFolder = arrayOfFilePathsInDocumentsFolder()
        return filesInFolder.filter(isIncluded)
    }
    
    func isIncluded(filepath : NSString) -> Bool {
        for excludedFilePath in self.arrayExistingFileNames {
            if excludedFilePath == filepath {
                return false
            }
        }
        return true
    }
    
    func arrayOfFilePathsInDocumentsFolder() -> Array<NSString> {
        
        let rootPath = NSString.appDocumentsDirectory()
        let enumerator = NSFileManager.defaultManager().enumeratorAtPath(rootPath)
        
        var filepathArray = Array<String>()
        while let filename = enumerator?.nextObject() as? NSString {
            if filename.pathExtension == Constants.FileExtensionUFW {
                let filepath = rootPath.stringByAppendingPathComponent(filename as String)
                filepathArray.append(filepath)
            }
        }
        
        return filepathArray
    }
    
    func importFileAtPath(path : String) -> Bool {
        
        if let data = NSFileManager.defaultManager().contentsAtPath(path) {
            let importer = UFWFileImporter(data: data)
            
            // If successfully import file, remove from disk and from the local list
            if importer.file.isValid && importer.importFile() {
                deleteFileForFilePath(path)
                removeDeletedFilesFromExistingFileList()
                saveFileList()
                return true
            }
        }
        return false
    }
    
    func addExistingFilePath(path : String) {
        let stringPath = path as NSString
        let matchingArray = self.arrayExistingFileNames.filter({ stringPath.isEqualToString($0) })
        if (matchingArray.count == 0) {
            self.arrayExistingFileNames.append(path)
            saveFileList()
        }
    }
    
    private func deleteFileForFilePath(path : String) -> Bool {
        
        if NSFileManager.defaultManager().fileExistsAtPath(path) {
            do {
                try NSFileManager.defaultManager().removeItemAtPath(path)
            }
            catch let error as NSError {
                print(error)
                return false
            }
        }
        return true
        
    }
    
    private func saveFileList() {
        if self.arrayExistingFileNames.count > 0 {
            let array = self.arrayExistingFileNames as NSArray
            array.writeToFile(iTunesSavedFilePath(), atomically: true)
        }
    }
    
    private func removeDeletedFilesFromExistingFileList() {
        
        let revisedFiles = self.arrayExistingFileNames.filter( {NSFileManager.defaultManager().fileExistsAtPath($0)} )
        self.arrayExistingFileNames = revisedFiles
        saveFileList()
    }
    
    private func iTunesSavedFilePath() -> String {
        return NSString.documentsDirectory().stringByAppendingPathComponent(Constants.ITunes.FilenameFiles)
    }
    
    private func retrieveExistingSavedFiles() -> NSArray {
        if let existingArray = NSArray(contentsOfFile: iTunesSavedFilePath() ) {
            return existingArray
        }
        else {
            return NSArray()
        }
    }

}