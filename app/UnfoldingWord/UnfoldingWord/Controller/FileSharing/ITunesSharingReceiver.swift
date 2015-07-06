//
//  ITunesSharingReceiver.swift
//  UnfoldingWord
//
//  Created by David Solberg on 7/5/15.
//

import Foundation

@objc final class ITunesSharingReceiver : NSObject {
    
    private var arrayExistingFileNames : Array<String>!
    
    override init() {
        super.init()
        self.arrayExistingFileNames = retrieveExistingSavedFiles() as! Array<String>
    }
    
    deinit {
        removeDeletedFilesFromExistingFileList()
    }
    
    func arrayOfNewFilePaths() -> Array<NSString> {
        
        let rootPath = NSString.appDocumentsDirectory()
        let enumerator = NSFileManager.defaultManager().enumeratorAtPath(rootPath)
        
        var filepathArray = Array<String>()
        while let filepath = enumerator?.nextObject() as? String {
            filepathArray.append(filepath)
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
            var error : NSError? = nil
            NSFileManager.defaultManager().removeItemAtPath(path, error: &error)
            if let error = error {
                println(error)
                return false
            }
            else {
                return true
            }
        }
        else {
            return true
        }
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