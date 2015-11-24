//
//  FileNamer.swift
//  UnfoldingWord
//
//  Created by David Solberg on 11/2/15.
//  Copyright © 2015 Acts Media Inc. All rights reserved.
//

import Foundation
import CoreData

@objc class FileNamer : NSObject {
    
    static let filePrefixText = "text_"
    
    static let filePrefixAudio = "audio_"
    static let fileSuffixAudio = ".mp3"
    static let separator = "|~|"
    
    static let filePrefixJSONText = "json_text_"
    static let fileSuffixJSONText = ".json"
    
    static let fileSuffixSignature = ".sig"
    
    static func signatureFileFromAudioFile(name : String) -> String {
        let suffixRange = NSMakeRange(name.characters.count-fileSuffixAudio.characters.count, fileSuffixAudio.characters.count)
        let stringWithoutFileSuffix = (name as NSString).stringByReplacingCharactersInRange(suffixRange, withString: "")
        return stringWithoutFileSuffix + fileSuffixSignature
    }
    
    static func nameForAudioSignatureBitrate(bitrate : UWAudioBitrate) -> String?
    {
        guard let baseName = baseNameAudioBitrate(bitrate) else { return nil }
        return baseName + fileSuffixSignature
    }
    
    static func nameForAudioBitrate(bitrate : UWAudioBitrate) -> String?
    {
        guard let baseName = baseNameAudioBitrate(bitrate) else { return nil }
        return baseName + fileSuffixAudio
    }
    
    static func baseNameAudioBitrate(bitrate : UWAudioBitrate) -> String?
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
        return "\(filePrefixAudio)" + "\(version.slug)" + "\(separator)" + "\(language.lc)" + "\(separator)" + "\(audiosource.chapter)" + "\(separator)" + "\(toc.slug)" + "\(separator)" + "\(bitrate.rate)"
    }
    
    static func audioBitrateForName(name : String) -> UWAudioBitrate?
    {
        let suffixRange = NSMakeRange(name.characters.count-fileSuffixAudio.characters.count, fileSuffixAudio.characters.count)
        let stringWithoutFileSuffix = (name as NSString).stringByReplacingCharactersInRange(suffixRange, withString: "")
        
        let prefixRange = NSMakeRange(0, filePrefixAudio.characters.count)
        let contentString = (stringWithoutFileSuffix as NSString).stringByReplacingCharactersInRange(prefixRange, withString: "")
        
        let parts = (contentString as NSString).componentsSeparatedByString(separator)
        guard parts.count == 5 else {
            assertionFailure("Could not compose the correct information from \(name). Got parts: \(parts)")
            return nil
        }
        
        let versionSlug = parts[0]
        let langCode = parts[1]
        let audioSourceChapter = parts[2]
        let tocSlug = parts[3]
        let bitrateValue = parts[4]
        
        guard let rate = Int(bitrateValue) else {
            assertionFailure("Could not compose the bitrate value from \(bitrateValue). Got parts: \(parts). Should be at 4th index.")
            return nil
        }
        
        let predRate = NSPredicate(format: "rate = %ld", rate)
        let predSourceChap = NSPredicate(format: "source.chapter = %@", audioSourceChapter)
        let predTOC = NSPredicate(format: "source.audio.media.toc.slug = %@", tocSlug)
        let predVers = NSPredicate(format: "source.audio.media.toc.version.slug = %@",  versionSlug)
        let predLangCode = NSPredicate(format: "source.audio.media.toc.version.language.lc = %@", langCode)
        let andPredicates = NSCompoundPredicate(andPredicateWithSubpredicates: [predRate, predSourceChap, predTOC, predVers, predLangCode])
        
        let request = NSFetchRequest(entityName: UWAudioBitrate.entityName())
        request.predicate = andPredicates;
        
        do {
            let bitrates = try DWSCoreDataStack.managedObjectContext().executeFetchRequest(request)
            guard bitrates.count > 0 else {
                print("No bitrates found for fetch request: \(request)")
                return nil
            }
            guard bitrates.count == 1 else {
                print("Multiple bitrates: \n \(bitrates)\n for fetch request: \(request)")
                return nil
            }
            guard let bitrate = bitrates[0] as? UWAudioBitrate else {
                print("Expected UWAudioBitrate. Instead got \(bitrates[0]) for fetch request: \(request)")
                return nil
            }
            return bitrate
        } catch let error {
            print("Fetch request: \(request)\n\n Returned error: \(error)")
            return nil
        }
    }
    
    static func nameForVersionText(version : UWVersion) -> String
    {
        return "\(filePrefixJSONText)\(version.slug)_\(version.language.lc)\(fileSuffixJSONText)"
    }
}
