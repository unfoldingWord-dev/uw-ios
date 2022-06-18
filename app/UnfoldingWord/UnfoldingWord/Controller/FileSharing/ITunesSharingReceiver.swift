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
    
    @objc override init() {
        super.init()
        self.arrayExistingFileNames = retrieveExistingSavedFiles() as! Array<String>
    }
    
    deinit {
        removeDeletedFilesFromExistingFileList()
    }
    
    @objc func filesToDisplayForImport() -> [String] {
        let filesInFolder = arrayOfFilePathsInDocumentsFolder()
        return filesInFolder.filter(isIncluded)
    }
    
    @objc func isIncluded(filepath : String) -> Bool {
        for excludedFilePath in self.arrayExistingFileNames {
            if excludedFilePath == filepath {
                return false
            }
        }
        return true
    }
    
    @objc func arrayOfFilePathsInDocumentsFolder() -> [String]  {
        
        let rootPath = NSString.appDocumentsDirectory()!
        let enumerator = FileManager.default.enumerator(atPath: rootPath)

        var filepathArray = [String]()
        while let filename = enumerator?.nextObject() as? NSString {
            if filename.pathExtension == Constants.FileExtensionUFW {
                let filepath = (rootPath as NSString).appendingPathComponent(filename as String)
                filepathArray.append(filepath)
            }
        }
        
        return filepathArray
    }
    
    @objc func importFileAtPath(path : String) -> Bool {
        
        if let data = FileManager.default.contents(atPath: path) as? NSData {
            let importer = UFWFileImporter(data: data)
            
            // If successfully import file, remove from disk and from the local list
            if importer.file.isValid && importer.importFile(), deleteFileForFilePath(path: path) {
                removeDeletedFilesFromExistingFileList()
                saveFileList()
                return true
            }
        }
        return false
    }
    
    @objc func addExistingFilePath(path : String) {
        let stringPath = path as NSString
        let matchingArray = self.arrayExistingFileNames.filter({ stringPath.isEqual(to: $0) })
        if (matchingArray.count == 0) {
            self.arrayExistingFileNames.append(path)
            saveFileList()
        }
    }
    
    private func deleteFileForFilePath(path : String) -> Bool {
        guard FileManager.default.fileExists(atPath: path) else { return true }
        do {
            try FileManager.default.removeItem(atPath: path)
            return true
        } catch {
            print(error)
            return false
        }
    }
    
    private func saveFileList() {
        if self.arrayExistingFileNames.count > 0 {
            let array = self.arrayExistingFileNames as NSArray
            _ = array.write(toFile: iTunesSavedFilePath(), atomically: true)
        }
    }
    
    private func removeDeletedFilesFromExistingFileList() {
        
        let revisedFiles = self.arrayExistingFileNames.filter( { FileManager.default.fileExists(atPath: $0) } )
        self.arrayExistingFileNames = revisedFiles
        saveFileList()
    }
    
    private func iTunesSavedFilePath() -> String {
        return (NSString.documentsDirectory() as NSString).appendingPathComponent(Constants.ITunes.FilenameFiles)
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
