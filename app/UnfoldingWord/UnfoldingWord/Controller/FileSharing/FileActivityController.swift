//
//  FileActivityController.swift
//  UnfoldingWord
//
//  Created by David Solberg on 6/22/15.
//

import Foundation
import UIKit

@objc class FileActivityController: NSObject {
    
    @objc let ufwVersion : UWVersion?
    @objc let isSend : Bool
    @objc let urlProvider : UFWFileActivityItemProvider?
    
    @objc init(version: UWVersion?, shouldSend : Bool) {
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
    
    @objc func activityViewController() -> UIActivityViewController? {
        
        if let version = self.ufwVersion, let provider = self.urlProvider {
            let items = [provider, version.filename() ?? ""] as [Any]
            let activityVC = UIActivityViewController(activityItems: items, applicationActivities: applicationActivities() )
            activityVC.excludedActivityTypes = [.postToWeibo, .postToTencentWeibo, .postToFacebook, .postToTwitter, .copyToPasteboard, .message, .print]
            return activityVC
        }
        else if self.isSend == false {
            let items = Array<String>()
            let activityVC = UIActivityViewController(activityItems: items, applicationActivities: applicationActivities() )
            activityVC.excludedActivityTypes = [.postToWeibo, .postToTencentWeibo, .postToFacebook, .postToTwitter, .copyToPasteboard, .message, .print, .mail]
            return activityVC
        }
        else {
            assertionFailure("No version or provider, and send is true.")
            return nil
        }
    }
    
    @objc func applicationActivities() -> [UFWActivity] {
        
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
    
    @objc func cleanup() {
        if let provider = self.urlProvider {
            provider.cleanup()
        }

    }
    
}
