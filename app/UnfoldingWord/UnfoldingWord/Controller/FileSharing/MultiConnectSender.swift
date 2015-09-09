//
//  MultiConnectSender.swift
//  UnfoldingWord
//
//  Created by David Solberg on 7/1/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

import Foundation
import MultipeerConnectivity

@objc final class MultiConnectSender : NSObject, MCNearbyServiceAdvertiserDelegate, MCSessionDelegate {
    
    let updateBlock : FileUpdateBlock
    let filename : NSString
    let localPeer : MCPeerID = MCPeerID(displayName:Constants.MultiConnect.PeerDisplaySender);
    var session : MCSession?
    var advertiser : MCNearbyServiceAdvertiser?
    var progress : NSProgress?
    
        
    init(dataToSend: NSData, filename: NSString, updateBlock: FileUpdateBlock) {
        self.updateBlock = updateBlock
        self.filename = filename
        self.session = nil
        self.advertiser = nil
        self.progress = nil
        super.init()
        saveData(dataToSend)
        advertise()
    }
    
    deinit {
        if let advertiser = self.advertiser {
            advertiser.stopAdvertisingPeer()
        }
        if let session = self.session {
            session.disconnect()
        }
    }

    
    // This sends an update to via a non-optional progress block
    func updateProgressWithConnected(connected: Bool, percent : Float, complete: Bool, error: Bool) {
        self.updateBlock(percentComplete: percent, connected: connected, complete: complete)
    }
    
    func advertise() {
        self.advertiser = MCNearbyServiceAdvertiser(peer: self.localPeer, discoveryInfo: nil, serviceType: Constants.MultiConnect.ServiceType)
        if let advertiser = self.advertiser {
            advertiser.delegate = self
            advertiser.startAdvertisingPeer() 
        }
    }
    
    func startSendingFileToPeer(peer : MCPeerID) {
        let url = NSURL(fileURLWithPath: temporaryFilePath())
        if let session = self.session
        {
            weak var weakself = self
            self.progress = session.sendResourceAtURL(url, withName: self.filename as String, toPeer: peer, withCompletionHandler: { (error) -> Void in
                if let
                    error = error,
                    strongself = weakself
                {
                    print("\(error.userInfo)")
                    strongself.updateProgressWithConnected(false, percent: 0, complete: false, error: true)
                }
            })
            
            if let progress = self.progress {
                progress.addObserver(self, forKeyPath:Constants.MultiConnect.KeyPathFractionCompleted, options: NSKeyValueObservingOptions.New, context: nil)
            }
            else {
                assertionFailure("Could not set up progress")
                updateProgressWithConnected(false, percent: 0, complete: false, error: true)
            }
        }
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

    func advertiser(advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: NSError) {
        self.updateBlock(percentComplete: 0, connected: false, complete: false)
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: (Bool, MCSession) -> Void) {
        if peerID.displayName == Constants.MultiConnect.PeerDisplayReceiver {
            
            let createdSession = MCSession(peer: self.localPeer)
            
            if let advertiser = self.advertiser {
                advertiser.stopAdvertisingPeer()
            }
            self.session = createdSession
            createdSession.delegate = self
            invitationHandler(true, createdSession)
            return;
            
        }
        invitationHandler(false, MCSession(peer: self.localPeer))
    }
    
    
    // Session Delegate
    // These are really only used by the receiver.
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        // not used with sendResourceAtURL
    }

    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
        print("the receiver will handle this because we're using sendResourceAtUrl")
    }
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        print("the receiver will handle this because we're using sendResourceAtUrl")
    }

    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        // not used
    }

    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        if state == MCSessionState.Connected && session == self.session {
            startSendingFileToPeer(peerID)
        }
    }
    
    func session(session: MCSession, didReceiveCertificate certificate: [AnyObject]?, fromPeer peerID: MCPeerID, certificateHandler: (Bool) -> Void) {
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
