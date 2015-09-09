//
//  FileActivityController.swift
//  UnfoldingWord
//
//  Created by David Solberg on 6/22/15.
//

import Foundation
import UIKit


@objc final class FileActivityController: NSObject {
    
    let ufwVersion : UWVersion?
    let isSend : Bool
    let urlProvider : UFWFileActivityItemProvider?
    
    init(version: UWVersion?, shouldSend : Bool) {
        self.ufwVersion = version
        self.isSend = shouldSend
        let placeHolder = NSURL(fileURLWithPath: NSString.documentsDirectory(), isDirectory: true)
        
        if shouldSend, let version = version {
            self.urlProvider = UFWFileActivityItemProvider(placeholderItem: placeHolder, version: version)
        }
        else {
            self.urlProvider = nil
        }
    }
    
    func activityViewController() -> UIActivityViewController? {
        
        if let version = self.ufwVersion, provider = self.urlProvider {
            let items = [provider, version.filename()]
            let activityVC = UIActivityViewController(activityItems: items, applicationActivities: applicationActivities() )
            activityVC.excludedActivityTypes = [UIActivityTypePostToWeibo, UIActivityTypePostToFacebook, UIActivityTypePostToTwitter,UIActivityTypeCopyToPasteboard, UIActivityTypeMessage, UIActivityTypePrint ]
            return activityVC
        }
        else if self.isSend == false {
            let items = Array<String>()
            let activityVC = UIActivityViewController(activityItems: items, applicationActivities: applicationActivities() )
            activityVC.excludedActivityTypes = [UIActivityTypePostToWeibo, UIActivityTypePostToFacebook, UIActivityTypePostToTwitter,UIActivityTypeCopyToPasteboard, UIActivityTypeMessage, UIActivityTypePrint, UIActivityTypeMail ]
            return activityVC
        }
        else {
            assertionFailure("No version or provider, and send is true.")
            return nil
        }
    }
    
    func applicationActivities() -> [UFWActivity] {
        
        if self.isSend {
            let bluetoothSend = UFWActivity(type: UFWActivityType.SendBluetooth)
            let wirelessSend = UFWActivity(type: UFWActivityType.SendMultiConnect)
            let itunesSend = UFWActivity(type: UFWActivityType.SendiTunes)
            return [bluetoothSend, wirelessSend, itunesSend]
        }
        else {
            let bluetoothReceive = UFWActivity(type: UFWActivityType.GetBluetooth)
            let wirelessReceive = UFWActivity(type: UFWActivityType.GetMultiConnect)
            let itunesReceive = UFWActivity(type: UFWActivityType.GetiTunes)
            return [bluetoothReceive, wirelessReceive, itunesReceive]
        }
    }
    
    func cleanup() {
        if let provider = self.urlProvider {
            provider.cleanup()
        }

    }
    
}
