//
//  NSData+ZipHelper.swift
//  UnfoldingWord
//
//  Created by David Solberg on 11/3/15.
//  Copyright © 2015 Acts Media Inc. All rights reserved.
//

import Foundation

extension NSData {
    
    func zippedData(filename : String) -> NSData?
    {
        let directory = NSString.cacheTempDirectory()
        let fullpath = directory.stringByAppendingPathComponent(filename)
        let zipper = SSZipArchive(path: fullpath)

        guard
            zipper.open &&
            zipper.writeData(self, filename: filename) && zipper.close
        else {
            assertionFailure("Could not write data to zip!")
            return nil
        }
        
        let result = NSData(contentsOfFile: fullpath)
        assert(result != nil, "Could not zip")
        do {
            try NSFileManager.defaultManager().removeItemAtPath(fullpath)
        }
        catch {
            assertionFailure("Could not delete file at path \(fullpath)")
        }
        
        return result
    }
    
    func unzippedData() -> NSData?
    {
        let directory = NSString.cacheTempDirectory()
        let inputFile = "input.zip"
        let inputPath = directory.stringByAppendingPathComponent(inputFile)
        
        guard self.writeToFile(inputPath, atomically: true) else {
            assertionFailure("Could not write input zip data to file!")
            return nil
        }
        
        let output = "files"
        let outputPath = directory.stringByAppendingPathComponent(output)
        
        guard SSZipArchive.unzipFileAtPath(inputPath, toDestination: outputPath) else {
            assertionFailure("Could not write output from zip to new file!")
            return nil
        }
        
        let enumerator = NSFileManager.defaultManager().enumeratorAtPath(outputPath)
        
        var filepath : String? = nil
        while let filename = enumerator?.nextObject() as? NSString {
            if filename.pathExtension == "txt" {
                filepath = outputPath.stringByAppendingPathComponent(filename as String)
                break;
            }
        }
        
        guard let finalPath = filepath else {
            assertionFailure("Could not find text file!")
            return nil
        }
        
        let result = NSData(contentsOfFile: finalPath)
        assert(result != nil, "Could not unzip")

        do {
            try NSFileManager.defaultManager().removeItemAtPath(inputPath)
            try NSFileManager.defaultManager().removeItemAtPath(outputPath)
        }
        catch {
            assertionFailure("Could not delete files at path \(inputPath) or \(outputPath)")
            return nil
        }
        
        return result
    }
    
    
}