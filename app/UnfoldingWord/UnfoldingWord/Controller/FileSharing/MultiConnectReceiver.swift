//
//  MultiConnectReceiver.swift
//  UnfoldingWord
//
//  Created by David Solberg on 7/2/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

import Foundation
import MultipeerConnectivity

@objc final class MultiConnectReceiver : NSObject, MCSessionDelegate, MCNearbyServiceBrowserDelegate {
    
    let updateBlock : FileUpdateBlock
    let localPeer : MCPeerID = MCPeerID(displayName:Constants.MultiConnect.PeerDisplayReceiver);
    var receivedFileData : NSData?
    var session : MCSession?
    var browser : MCNearbyServiceBrowser?
    var progress : NSProgress?
    
    
    init(updateBlock: FileUpdateBlock) {
        self.updateBlock = updateBlock
        self.receivedFileData = nil
        self.session = nil
        self.browser = nil
        self.progress = nil
        super.init()
        browse()
    }
    
    deinit {
        browser?.stopBrowsingForPeers()
        session?.disconnect()
    }
    
    
    // This sends an update to via a non-optional progress block
    func updateProgressWithConnected(connected: Bool, percent : Float, complete: Bool, error: Bool) {
        self.updateBlock(percentComplete: percent, connected: connected, complete: complete)
    }
    
    func browse() {
        self.browser = MCNearbyServiceBrowser(peer: self.localPeer, serviceType: Constants.MultiConnect.ServiceType)
        self.browser?.delegate = self
        self.browser?.startBrowsingForPeers()
    }
    
    // MCNearbyServiceBrowserDelegate Methods
    func browser(browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: NSError) {
        updateProgressWithConnected(false, percent: 0, complete: false, error: true)
    }
    
    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        
        browser.stopBrowsingForPeers()
        if self.session != nil {             // We already have a session
            return;
        }
        let session = MCSession(peer: localPeer)
        self.session = session
        session.delegate = self
        browser.invitePeer(peerID, toSession: session, withContext: nil, timeout: 30.0)
    }
    
    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        updateProgressWithConnected(false, percent: 0, complete: false, error: true)
    }

    
    // We're observing our NSProgress item to get updates as the file is sent
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == Constants.MultiConnect.KeyPathFractionCompleted {
            if let progress = self.progress {
                let percent = Float(progress.fractionCompleted)
                let connected = progress.cancelled
                updateProgressWithConnected(connected, percent: percent, complete: false, error: false)
            }
        }
        else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    
    // Session Delegate
    // These are really only used by the receiver.
    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        // not used with sendResourceAtURL
    }
    
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
        progress.addObserver(self, forKeyPath:Constants.MultiConnect.KeyPathFractionCompleted, options: NSKeyValueObservingOptions.New, context: nil)
        self.progress = progress
        updateProgressWithConnected(true, percent: 0.0, complete: false, error: false)
    }
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        
        session.disconnect()
        if let error = error {
            print("\(error.userInfo)")
            updateProgressWithConnected(false, percent: 1.0, complete: false, error: true)
            return
        }
        else if let path = localURL.path {
            self.receivedFileData = NSFileManager.defaultManager().contentsAtPath(path)
            updateProgressWithConnected(false, percent: 1.0, complete: true, error: false)
            return
        }
        
        updateProgressWithConnected(false, percent: 1.0, complete: false, error: true)
    }
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    
    
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        if state == MCSessionState.NotConnected {
            self.session = nil
            self.browser?.startBrowsingForPeers()
        }
        if state == MCSessionState.Connected {
            updateProgressWithConnected(true, percent: 0, complete: false, error: false)
        }
    }
    
    func session( session: MCSession, didReceiveCertificate certificate: [AnyObject]?, fromPeer peerID: MCPeerID,  certificateHandler: ((Bool) -> Void)) {
        certificateHandler(true)
    }
    
    // Helpers
    
    func saveData(data : NSData) {
        NSFileManager.defaultManager().createFileAtPath(temporaryFilePath(), contents: data, attributes: nil)
    }
    
    func temporaryFilePath() -> String {
        return NSString.cachesDirectory().stringByAppendingPathComponent(Constants.MultiConnect.FilePathSend)
    }
}
