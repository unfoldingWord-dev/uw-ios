//
//  Constants.swift
//  UnfoldingWord
//
//  Created by David Solberg on 6/16/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

import Foundation

// Percent complete is an Int from 0 to 100. 100 indicates that the transfer is complete.
typealias FileUpdateBlock = (percentComplete: Float, connected : Bool) -> ()

struct Constants {
    struct URLSource {
        static let signature = "sig"
        static let open_chapter = "chapters"
    }
    
    struct FileFormat {
        static let TopLevel = "top"
        static let SourcesArray = "sources"
    }
    
    struct JSONName {
        static let Languages = "langs" // duplicated in UWTopContainer.h
        static let Versions = "vers" // duplicated in UWLanguage.h
    }
    
    static let SignatureFileAppend = ".sig" // duplicated in Constants.h
    
    static let FileExtension = "ufw"
    
    struct Bluetooth {
        static let SERVICE_UUID = "5440DDE8-3C15-4E96-A949-25F062A0142E"
        static let CHARACTERISTIC_UUID = "45C060F5-4169-47D2-ADED-ACD0C0A2F9E5"
        static let MAX_SIZE = 20
        static let EndOfMessage = "-_EOM_-"
        static let MessageSize = "-_SIZE_-"
    }
}
