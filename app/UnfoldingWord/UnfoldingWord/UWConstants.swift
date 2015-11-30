//
//  Constants.swift
//  UnfoldingWord
//
//  Created by David Solberg on 6/16/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

import Foundation

// From http://stackoverflow.com/questions/24034544/dispatch-after-gcd-in-swift/24318861#24318861
func delay(delay:Double, closure: () -> Void ) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

// Percent complete is an Int from 0 to 100. 100 indicates that the transfer is complete.
typealias ButtonPressBlock = () -> Void

// Percent complete is an Int from 0 to 100. 100 indicates that the transfer is complete.
typealias FileUpdateBlock = (percentComplete: Float, connected : Bool, complete : Bool) -> ()

typealias ITunesPickerChooseBlock = (canceled : Bool, chosenPath : String?) -> ()

typealias AudioDownloadCompletionBlock = (success : Bool, data : NSData?) -> ()
typealias AudioDownloadProgressBlock = (percentDone : Float) -> ()

typealias AudiQualitySelectionBlock = (isLowQuality : Bool) -> Void

enum ActionType {
    case Audio
    case Video
    case font
    case Diglot
    case Share
}

func FONT_LIGHT() -> UIFont { // duplicated in Constants.h
    return UIFont(name: "HelveticaNeue-Light", size: 17)!
}

func FONT_NORMAL() -> UIFont { // duplicated in Constants.h
    return UIFont(name: "HelveticaNeue", size: 17)!
}

func FONT_MEDIUM() -> UIFont { // duplicated in Constants.h
    return UIFont(name: "HelveticaNeue-Medium", size: 17)!
}

func BACKGROUND_GREEN() -> UIColor { // duplicated in Constants.h
    return UIColor(red: 0.0, green: 0.588, blue: 0.533, alpha: 1)
}

struct Constants {
    
    struct Audio {
        static let framerateDefault : Float64 = 44100
    }

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
    
    static let FileExtensionUFW = "ufw" // duplicated in Constants.h
    
    static let USFM_VERSE_NUMBER = "USFMVerseNumber" // duplicated in Constants.h
    
    struct Bluetooth {
        static let SERVICE_UUID = "5440DDE8-3C15-4E96-A949-25F062A0142E"
        static let CHARACTERISTIC_UUID = "45C060F5-4169-47D2-ADED-ACD0C0A2F9E5"
        static let MAX_SIZE = 20
        static let EndOfMessage = "-_EOM_-"
        static let MessageSize = "-_SIZE_-"
    }
    
    struct MultiConnect {
        static let KeyPathFractionCompleted = "fractionCompleted"
        static let ServiceType = "ufw-mc-service"
        static let PeerDisplaySender = "UnfoldingWord Sender"
        static let PeerDisplayReceiver = "UnfoldingWord Receiver"
        static let FilePathSend = "FileToSend.json"
        static let FilePathReceive = "FileToReceive.json"
    }
    
    struct Activity { // duplicated in Constants.h
        static let BluetoothSend = "BluetoothSend"
        static let BluetoothReceive = "BluetoothReceive"
        
        static let MultiConnectSend = "MultiConnectSend"
        static let MultiConnectReceive = "MultiConnectReceive"

        static let iTunesSend = "iTunesSend"
        static let iTunesReceive = "iTunesReceive"
    }
    
    struct ITunes {
        static let FilenameFiles = "ProcessedITunesFiles.archive"
    }
    
    static let Image_Diglot = "diglot"
}

