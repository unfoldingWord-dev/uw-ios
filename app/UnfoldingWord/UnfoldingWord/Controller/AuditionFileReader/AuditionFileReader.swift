//
//  AuditionFileReader.swift
//  UnfoldingWord
//
//  Created by David Solberg on 10/4/15.
//  Copyright © 2015 Acts Media Inc. All rights reserved.
//

import Foundation

typealias FileInfoCompletion = (audioFileInfo : AudioFileInfo?) -> Void

// Ideally this would be a struct, but it needs to work in objective-c
@objc class AudioFileInfo : NSObject {
    
    private var arrayTimes : [Float64]
    
    init(times: [Float64]) {
        self.arrayTimes = times
        super.init()
    }
    
    var numberOfChapters : Int {
        get {
            return arrayTimes.count
        }
    }
    
    func startTimeForChapter(number : Int) -> Float {
        if number > numberOfChapters || number < 1 {
            assertionFailure("There is no chapter \(number)")
            return 0
        }
        let time = arrayTimes[number-1]
        return Float(time)
    }
}

@objc class AuditionFileReader : NSObject {
    
    class func parseFileUrl(url : NSURL, completion : FileInfoCompletion) {
        let data = NSData(contentsOfURL: url)
        parseFileData(data, completion: completion)
    }

    class func parseFileData(data : NSData?, completion: FileInfoCompletion) {
        
        guard let
            data = data,
            audioFileAsString = NSString(data: data, encoding: NSASCIIStringEncoding),
            stringToParse = trackXMLFromString(audioFileAsString) else
        {
            completion(audioFileInfo: nil)
            return
        }
        
        XMLConverter.convertXMLString(stringToParse, completion: { (success: Bool, dictionary : NSDictionary?, error : NSError? ) -> Void in
            
            guard let dictionary = dictionary where success == true else {
                completion(audioFileInfo: nil)
                return
            }
            
            let times = self.timesFromAuditionDictionary(dictionary)
            let timeInfo = AudioFileInfo(times: times)
            
            if times.count > 0 {
                completion(audioFileInfo: timeInfo)
            }
            else {
                completion(audioFileInfo: nil)
            }
        })
    }
    
    static func trackXMLFromString(string : NSString) -> String?
    {
        let startTracksRange = string.rangeOfString("<xmpDM:Tracks>")
        let endTracksRange = string.rangeOfString("</xmpDM:Tracks>")
        
        if startTracksRange.location == NSNotFound || endTracksRange.location == NSNotFound {
            return nil
        }
        
        let locationDifference = endTracksRange.location - startTracksRange.location
        let totalLength = locationDifference + endTracksRange.length
        
        let tracksRange = NSMakeRange(startTracksRange.location, totalLength)
        
        let stringToParse = string.substringWithRange(tracksRange)
        
        return stringToParse
    }
    
    static func timesFromAuditionDictionary(dictionary : NSDictionary) -> [Float64] {
        
        let frameRate = frameRateFromAuditionDictionary(dictionary)
        
        var times = [Float64]()
        
        guard
            let tracks = dictionary["xmpDM:Tracks"] as? NSDictionary,
            let bag = tracks["rdf:Bag"] as? NSDictionary,
            let lines = bag["rdf:li"] as? NSArray,
            let markerLine = lines.firstObject as? NSDictionary,
            let markerDescrip = markerLine["rdf:Description"] as? NSDictionary,
            let markersDic = markerDescrip["xmpDM:markers"] as? NSDictionary,
            let sequenceDic = markersDic["rdf:Seq"] as? NSDictionary,
            let markerArray = sequenceDic["rdf:li"] as? NSArray
            else
        { return times }
        
        
        
        for (_, markerItem) in markerArray.enumerate() {
            guard
                let marker = markerItem as? NSDictionary,
                let description = marker["rdf:Description"] as? NSDictionary,
                let startTime = description["-xmpDM:startTime"] as? NSString
                else { continue }
             
            let frameMarkerRange = startTime.rangeOfString("f")
            if frameMarkerRange.location == NSNotFound {
                if (startTime.length == 1) {
                    times.append(Float64(startTime.integerValue))
                }
                else {
                    let timeInSeconds = Float64(startTime.integerValue) / frameRate
                    times.append(timeInSeconds)
                }
            }
            else {
                let framesString = startTime.substringWithRange(NSMakeRange(0, frameMarkerRange.location)) as NSString
                let divisorString = startTime.substringWithRange(NSMakeRange(frameMarkerRange.location+1, startTime.length - frameMarkerRange.location - 1)) as NSString
                let timeInSeconds = Float64(framesString.intValue) / Float64(divisorString.intValue)
                times.append(timeInSeconds)
            }
        }
        return times
    }
    
    static func frameRateFromAuditionDictionary(dictionary : NSDictionary) -> Float64 {
        
        guard
            let tracks = dictionary["xmpDM:Tracks"] as? NSDictionary,
            let bag = tracks["rdf:Bag"] as? NSDictionary,
            let lines = bag["rdf:li"] as? NSArray,
            let markerLine = lines.firstObject as? NSDictionary,
            let markerDescrip = markerLine["rdf:Description"] as? NSDictionary,
            let frameRateString = markerDescrip["-xmpDM:frameRate"] as? NSString
            else
        { return Constants.Audio.framerateDefault }
        
        let frame = frameRateString.stringByTrimmingCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet) as NSString
        
        let frameRate = Float64(frame.integerValue)
        if frameRate <= 0 {
            return Constants.Audio.framerateDefault
        }
        else {
            return frameRate
        }
    }
}