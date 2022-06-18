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
    @objc var receivedFileData : Data?
    var session : MCSession?
    var browser : MCNearbyServiceBrowser?
    var progress : Progress?
    
    
    @objc init(updateBlock: @escaping FileUpdateBlock) {
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
        self.updateBlock(percent, connected, complete)
    }
    
    func browse() {
        self.browser = MCNearbyServiceBrowser(peer: self.localPeer, serviceType: Constants.MultiConnect.ServiceType)
        self.browser?.delegate = self
        self.browser?.startBrowsingForPeers()
    }
    
    // MCNearbyServiceBrowserDelegate Methods
    private func browser(browser: MCNearbyServiceBrowser!, didNotStartBrowsingForPeers error: NSError!) {
        updateProgressWithConnected(connected: false, percent: 0, complete: false, error: true)
    }
    
    func browser(browser: MCNearbyServiceBrowser!, foundPeer peerID: MCPeerID!, withDiscoveryInfo info: [NSObject : AnyObject]!) {
        browser.stopBrowsingForPeers()
        if self.session != nil {
            return
        }
        let session = MCSession(peer: localPeer)
        session.delegate = self
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 30.0)
        self.session = session
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        updateProgressWithConnected(connected: false, percent: 0, complete: false, error: true)
    }
    
    // We're observing our NSProgress item to get updates as the file is sent
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == Constants.MultiConnect.KeyPathFractionCompleted {
            if let progress = self.progress {
                let percent = Float(progress.fractionCompleted)
                let connected = progress.isCancelled
                updateProgressWithConnected(connected: connected, percent: percent, complete: false, error: false)
            }
        }
        else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    
    // Session Delegate
    // These are really only used by the receiver.

    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) { }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        // not used with sendResourceAtURL
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        progress.addObserver(self, forKeyPath:Constants.MultiConnect.KeyPathFractionCompleted, options: NSKeyValueObservingOptions.new, context: nil)
        self.progress = progress
        updateProgressWithConnected(connected: true, percent: 0.0, complete: false, error: false)
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
        session.disconnect()
        if error != nil {
            updateProgressWithConnected(connected: false, percent: 1.0, complete: false, error: true)
            return
        }

        if let path = localURL?.path {
            self.receivedFileData = FileManager.default.contents(atPath: path)
            updateProgressWithConnected(connected: false, percent: 1.0, complete: true, error: false)
            return
        }

        updateProgressWithConnected(connected: false, percent: 1.0, complete: false, error: true)
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) { }

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        if state == .notConnected {
            self.session = nil
            self.browser?.startBrowsingForPeers()
        }
        if state == .connected {
            updateProgressWithConnected(connected: true, percent: 0, complete: false, error: false)
        }
    }
    
    func session( session: MCSession!, didReceiveCertificate certificate: [AnyObject]!, fromPeer peerID: MCPeerID!,  certificateHandler: ((Bool) -> Void)!) {
        certificateHandler(true)
    }
    
    // Helpers
    
    func saveData(data : Data) {
        FileManager.default.createFile(atPath: temporaryFilePath(), contents: data, attributes: nil)
    }
    
    func temporaryFilePath() -> String {
        return (NSString.cachesDirectory() as NSString).appendingPathComponent(Constants.MultiConnect.FilePathSend)
    }
}
