//
//  String+Zip.swift
//  UnfoldingWord
//
//  Created by David Solberg on 11/18/15.
//  Copyright © 2015 Acts Media Inc. All rights reserved.
//

import Foundation

extension String {
    
    /// Returns the path to files enclosed in the zip data. WARNING: The files at the path are immediately deleted. If you want to keep the files, copy and/or more them in the same run loop.
    func unzippedDataFromPathToPath() -> String?
    {
        let directory = NSString.cacheTempDirectory()
        let output = "files"
        let outputPath = directory.stringByAppendingPathComponent(output)
        
        guard SSZipArchive.unzipFileAtPath(self, toDestination: outputPath) else {
            assertionFailure("Could not write output from zip to new file!")
            return nil
        }
        
        delay(1.0) { () -> Void in
            outputPath.deleteFileOrFolder()
        }
        
        return outputPath
    }
    

    
    
}
