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
    let filename : String
    let localPeer : MCPeerID = MCPeerID(displayName:Constants.MultiConnect.PeerDisplaySender);
    var session : MCSession?
    var advertiser : MCNearbyServiceAdvertiser?
    var progress : Progress?
    
        
    @objc init(dataToSend: Data, filename: String, updateBlock: @escaping FileUpdateBlock) {
        self.updateBlock = updateBlock
        self.filename = filename
        self.session = nil
        self.advertiser = nil
        self.progress = nil
        super.init()
        saveData(data: dataToSend)
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
        self.updateBlock(percent, connected, complete)
    }
    
    func advertise() {
        self.advertiser = MCNearbyServiceAdvertiser(peer: self.localPeer, discoveryInfo: nil, serviceType: Constants.MultiConnect.ServiceType)
        if let advertiser = self.advertiser {
            advertiser.delegate = self
            advertiser.startAdvertisingPeer() 
        }
    }
    
    func startSendingFileToPeer(peer : MCPeerID) {
        let url = URL(fileURLWithPath: temporaryFilePath())
        if let session = self.session {
            self.progress = session.sendResource(at: url, withName: self.filename, toPeer: peer, withCompletionHandler: { [weak self] (error) -> Void in
                if error != nil {
                    self?.updateProgressWithConnected(connected: false, percent: 0, complete: false, error: true)
                }
            })
            
            if let progress = self.progress {
                progress.addObserver(self, forKeyPath:Constants.MultiConnect.KeyPathFractionCompleted, options: NSKeyValueObservingOptions.new, context: nil)
            }
            else {
                assertionFailure("Could not set up progress")
                updateProgressWithConnected(connected: false, percent: 0, complete: false, error: true)
            }
        }
    }
    
    // We're observing our NSProgress item to get updates as the file is sent
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)  {
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
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        self.updateBlock(0, false, false)
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
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
        invitationHandler(false, nil)
    }

    
    // Session Delegate
    // These are really only used by the receiver.
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID)  {
        // not used with sendResourceAtURL
    }

    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("the receiver will handle this because we're using sendResourceAtUrl")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        print("the receiver will handle this because we're using sendResourceAtUrl")
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) { }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        if state == .connected && session == self.session {
            startSendingFileToPeer(peer: peerID)
        }
    }

    func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        certificateHandler(true)
    }
    
    // Helpers
    
    func saveData(data: Data) {
        FileManager.default.createFile(atPath: temporaryFilePath(), contents: data, attributes: nil)
    }
    
    func temporaryFilePath() -> String {
        return (NSString.cachesDirectory() as NSString).appendingPathComponent(Constants.MultiConnect.FilePathSend)
    }
}
