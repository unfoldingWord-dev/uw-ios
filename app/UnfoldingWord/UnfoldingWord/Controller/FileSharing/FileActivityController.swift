//
//  FileActivityController.swift
//  UnfoldingWord
//
//  Created by David Solberg on 6/22/15.
//

import Foundation
import UIKit


@objc final class FileActivityController: NSObject {
    
    let isSend : Bool
    let itemProvider : UFWFileActivityItemProvider?
    
    init(queue: VersionQueue?, shouldSend : Bool) {
        self.isSend = shouldSend
        let placeHolder = NSURL(fileURLWithPath: NSString.documentsDirectory(), isDirectory: true)
        
        if shouldSend, let queue = queue {
            self.itemProvider = UFWFileActivityItemProvider(placeholderItem: placeHolder, queue: queue)
        }
        else {
            self.itemProvider = nil
        }
    }
    
    func activityViewController() -> UIActivityViewController? {
        
        if isSend, let provider = itemProvider {
            let items = [provider]
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
        
        if isSend {
            let bluetoothSend = UFWActivity(type: UFWActivityType.SendBluetooth)
            let wirelessSend = UFWActivity(type: UFWActivityType.SendMultiConnect)
            let itunesSend = UFWActivity(type: UFWActivityType.SendiTunes)
            if itemProvider?.queue.count > 1 {
                return [wirelessSend, itunesSend]
            } else {
                return [wirelessSend, itunesSend, bluetoothSend]
            }
        }
        else {
            let bluetoothReceive = UFWActivity(type: UFWActivityType.GetBluetooth)
            let wirelessReceive = UFWActivity(type: UFWActivityType.GetMultiConnect)
            let itunesReceive = UFWActivity(type: UFWActivityType.GetiTunes)
            return [bluetoothReceive, wirelessReceive, itunesReceive]
        }
    }
    
}
