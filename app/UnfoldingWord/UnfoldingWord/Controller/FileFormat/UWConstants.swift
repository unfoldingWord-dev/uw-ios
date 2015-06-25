//
//  Constants.swift
//  UnfoldingWord
//
//  Created by David Solberg on 6/16/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

import Foundation

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
        static let SERVICE_UUID = "E20A39F4-73F5-4BC4-A12F-17D1AD07A961"
        static let CHARACTERISTIC_UUID = "08590F7E-DB05-467E-8757-72F6FAEB13D4"
        static let MAX_SIZE = 20
        static let EndOfMessage = "_EOM_"
    }
}
