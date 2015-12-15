//
//  MultiConnectSender.swift
//  UnfoldingWord
//
//  Created by David Solberg on 7/1/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

import Foundation
import MultipeerConnectivity

struct FilePackage {
    let url: NSURL
    let filename: String
}

@objc final class MultiConnectSender : NSObject, MCNearbyServiceAdvertiserDelegate, MCSessionDelegate {
    
    let updateBlock : FileUpdateBlock
    let queue : VersionQueue
    let countTotal : Int
    var package: FilePackage? = nil
    let localPeer : MCPeerID
    var session : MCSession?
    var advertiser : MCNearbyServiceAdvertiser?
    var progress : NSProgress?
        
    init(queue: VersionQueue, updateBlock: FileUpdateBlock) {
        self.updateBlock = updateBlock
        self.queue = queue
        self.countTotal = queue.count
        let peerName = (Constants.MultiConnect.PeerDisplaySender as NSString).stringByAppendingFormat(".%ld", queue.count) as String
        self.localPeer = MCPeerID(displayName:peerName);

        self.session = nil
        self.advertiser = nil
        self.progress = nil
        super.init()
        advertise()
    }
    
    deinit {
        if let advertiser = self.advertiser {
            advertiser.stopAdvertisingPeer()
        }
        if let session = self.session {
            session.disconnect()
        }
        deleteCurrentFileIfExists()
    }
    
    private func deleteCurrentFileIfExists() {
        if let package = package, path = package.url.path where NSFileManager.defaultManager().fileExistsAtPath(path) {
            do { try NSFileManager.defaultManager().removeItemAtURL(package.url) } catch {}
        }
    }
    
    func prepareNextFilePackage() -> FilePackage?
    {
        guard let
            info = queue.popVersionSharingInfo(),
            fileUrl = info.fileSource()
        else {
            assertionFailure("Don't call this method unless there is another package. Check with queue.count")
            return nil
        }
        
        return FilePackage(url: fileUrl, filename: info.version.name)
    }

    // This sends an update to via a non-optional progress block
    func updateProgressWithConnected(connected: Bool, percent : Float, complete: Bool, error: Bool) {
        let shareCompleted = Float(queue.count)/Float(countTotal)
        let adjusted = percent / Float(queue.count)
        self.updateBlock(percentComplete: shareCompleted+adjusted, connected: connected, complete: complete, fileUrl: nil)
    }
    
    func advertise() {
        self.advertiser = MCNearbyServiceAdvertiser(peer: self.localPeer, discoveryInfo: nil, serviceType: Constants.MultiConnect.ServiceType)
        if let advertiser = self.advertiser {
            advertiser.delegate = self
            advertiser.startAdvertisingPeer() 
        }
    }
    
    func startSendingFileToPeer(peer : MCPeerID) {
        guard let nextPackage = prepareNextFilePackage(), session = self.session else {
            updateProgressWithConnected(false, percent: 0, complete: false, error: true)
            return
        }
        package = nextPackage
        
        self.progress = session.sendResourceAtURL(nextPackage.url, withName: nextPackage.filename, toPeer: peer, withCompletionHandler: { [weak self] (error) -> Void in
            guard let strong = self else { return }
            if let error = error {
                strong.deleteCurrentFileIfExists()
                strong.session?.disconnect()
                print("\(error.userInfo)")
                strong.updateProgressWithConnected(false, percent: 0, complete: false, error: true)
            } else {
                if strong.queue.count > 0 {
                    strong.deleteCurrentFileIfExists()
                    strong.startSendingFileToPeer(peer)
                } else {
                    strong.session?.disconnect()
                    strong.updateProgressWithConnected(false, percent: 1, complete: true, error: false)
                }
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
        self.updateBlock(percentComplete: 0, connected: false, complete: false, fileUrl: nil)
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: (Bool, MCSession) -> Void) {
        if (peerID.displayName as NSString).rangeOfString(Constants.MultiConnect.PeerDisplayReceiver).location != NSNotFound {
            
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
}
