//
//  FileNamer.swift
//  UnfoldingWord
//
//  Created by David Solberg on 11/2/15.
//  Copyright © 2015 Acts Media Inc. All rights reserved.
//

import Foundation

@objc class FileNamer : NSObject {
    
    static func nameForAudioBitrate(bitrate : UWAudioBitrate) -> String?
    {
        guard let
            audiosource = bitrate.source,
            toc = audiosource.audio.media.toc,
            version = toc.version,
            language = version.language
            else {
                assertionFailure("Not all elements were found for the filename for the audio bitrate!")
                return nil
        }
        
        return "audio_\(version.slug)_\(language.lc)_ch\(audiosource.chapter)_\(toc.slug)_br\(bitrate.rate).mp3"
    }
    
    static func nameForVersion(version : UWVersion) -> String 
    {
        return "text_\(version.slug)_\(version.language.lc).txt"
    }
}
