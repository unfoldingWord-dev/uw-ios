//
//  ITunesActivity.swift
//  UnfoldingWord
//
//  Created by David Solberg on 7/8/15.
//

import Foundation

enum UFWActivityType {
    case SendBluetooth
    case SendiTunes
    case SendMultiConnect
    case GetBluetooth
    case GetiTunes
    case GetMultiConnect
}

class UFWActivity : UIActivity {
    
    let type : UFWActivityType
    
    init(type : UFWActivityType) {
        self.type = type
        super.init()
    }
    
    override func activityType() -> String? {
        
        switch self.type {
        case .SendBluetooth:
            return Constants.Activity.BluetoothSend
        case .SendiTunes:
            return Constants.Activity.iTunesSend
        case .SendMultiConnect:
            return Constants.Activity.MultiConnectSend
        case .GetBluetooth:
            return Constants.Activity.BluetoothReceive
        case .GetiTunes:
            return Constants.Activity.iTunesReceive
        case .GetMultiConnect:
            return Constants.Activity.MultiConnectReceive
        }
    }
    
    override func activityTitle() -> String? {
        
        switch self.type {
        case .SendBluetooth:
            return "Send"
        case .SendiTunes:
            return "Save"
        case .SendMultiConnect:
            return "Send"
        case .GetBluetooth:
            return "Receive"
        case .GetiTunes:
            return "Import"
        case .GetMultiConnect:
            return "Receive"
        }
    }
    
    override func activityImage() -> UIImage? {
        switch self.type {
        case .SendBluetooth, .GetBluetooth:
            if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
                return UIImage(named: "BluetoothActivityiPad")
            }
            else {
                return UIImage(named: "BluetoothActivityiPhone")
            }

        case .SendiTunes, .GetiTunes:
            if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
                return UIImage(named: "iTunesActivityiPad")
            }
            else {
                return UIImage(named: "iTunesActivityiPhone")
            }

        case .SendMultiConnect, .GetMultiConnect:
            if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
                return UIImage(named: "WirelessActivityiPad")
            }
            else {
                return UIImage(named: "WirelessActivityiPhone")
            }
        }
    }
    
    override func canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool {
//        for anObject in activityItems {
//            if anObject is NSURL {
//                let url = anObject as! NSURL
//                if url.isFileReferenceURL() {
                    return true
//                }
//            }
//        }
//        return false
    }
    
    override func prepareWithActivityItems(activityItems: [AnyObject]) {
        // required to override this method, but we don't need to actually do anything.
    }
    
    override func performActivity() {
        // This is just a shell. We'll get the fact that the activity is completed, and then return our own UI
    }
    
    override class func activityCategory() -> UIActivityCategory {
        return UIActivityCategory.Share
    }
}
