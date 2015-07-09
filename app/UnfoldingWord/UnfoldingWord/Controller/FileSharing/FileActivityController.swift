//
//  FileActivityController.swift
//  UnfoldingWord
//
//  Created by David Solberg on 6/22/15.
//

import Foundation
import UIKit

@objc final class FileActivityController: NSObject {
    
    private let version : UWVersion
    private let urlProvider : UFWFileActivityItemProvider
    
    init(version: UWVersion) {
        self.version = version
        
        let placeHolder = NSURL(fileURLWithPath: NSString.documentsDirectory(), isDirectory: true)
        self.urlProvider = UFWFileActivityItemProvider(placeholderItem: placeHolder!, version: self.version)
    }
    
    func activityViewController() -> UIActivityViewController? {
        
        let items = [self.urlProvider, self.version.filename()]
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: applicationActivities() )
        activityVC.excludedActivityTypes = [UIActivityTypePostToWeibo, UIActivityTypePostToFacebook, UIActivityTypePostToTwitter,UIActivityTypeCopyToPasteboard, UIActivityTypeMessage, UIActivityTypePrint ];
        return activityVC
    }
    
    func applicationActivities() -> [UFWActivity] {
        let bluetoothSend = UFWActivity(type: UFWActivityType.SendBluetooth)
        let wirelessSend = UFWActivity(type: UFWActivityType.SendMultiConnect)
        let itunesSend = UFWActivity(type: UFWActivityType.SendiTunes)
        
        let bluetoothReceive = UFWActivity(type: UFWActivityType.GetBluetooth)
        let wirelessReceive = UFWActivity(type: UFWActivityType.GetMultiConnect)
        let itunesReceive = UFWActivity(type: UFWActivityType.GetiTunes)
        
        return [bluetoothSend, wirelessSend, itunesSend, bluetoothReceive, wirelessReceive, itunesReceive]
    }
    
    func cleanup() {
        self.urlProvider.cleanup()
    }
    
}
