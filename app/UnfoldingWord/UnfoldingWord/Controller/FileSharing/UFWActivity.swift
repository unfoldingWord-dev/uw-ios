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
            return "Send by Bluetooth"
        case .SendiTunes:
            return "Save to iTunes"
        case .SendMultiConnect:
            return "Send by Wireless"
        case .GetBluetooth:
            return "Receive by Bluetooth"
        case .GetiTunes:
            return "Import from iTunes"
        case .GetMultiConnect:
            return "Receive by Wireless"
        }
    }
    
    override func activityImage() -> UIImage? {
        switch self.type {
        case .SendBluetooth, .GetBluetooth:
            return UIImage(named: "bluetoothActivity.png")
        case .SendiTunes, .GetiTunes:
            return UIImage(named: "iTunesActivity.png")
        case .SendMultiConnect, .GetMultiConnect:
            return UIImage(named: "wirelessActivity.png")
        }
    }
    
    override func canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool {
        
        switch self.type {
        case .SendBluetooth, .SendiTunes, .SendMultiConnect:
            for anObject in activityItems {
                if anObject is NSURL {
                    return true
                }
            }
            return false
        case .GetBluetooth, .GetiTunes, .GetMultiConnect:
            return true
        }
    }
    
    override func prepareWithActivityItems(activityItems: [AnyObject]) {
        // required to override this method, but we don't need to actually do anything here.
    }
    
    override func performActivity() {
        activityDidFinish(true)
        // Just a shell. We'll just say the activity completed. Then the view controller will handle the actual work.
    }
    
    override class func activityCategory() -> UIActivityCategory {
        return UIActivityCategory.Share
    }
}
