//
//  BluetoothFileSender.swift
//  UnfoldingWord
//
//  Created by David Solberg on 6/22/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

import Foundation
import CoreBluetooth

enum SendStatus {
    case NotReady
    case ReadyToStart
    case InProgress
    case Complete
}

@objc final class BluetoothFileSender : NSObject, CBPeripheralManagerDelegate {
    
    lazy var manager : CBPeripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    var characteristic : CBMutableCharacteristic?
    let data : NSData
    var sendIndex : Int = 0
    var status = SendStatus.NotReady
    let updateBlock : FileUpdateBlock
    
    @objc init(dataToSend: NSData, updateBlock: @escaping FileUpdateBlock) {
        self.data = dataToSend
        self.updateBlock = updateBlock
        super.init()
        if self.manager.state == .resetting {
            self.sendIndex = -1 // to ensure that the manager is lazy initialized and indicate there is no connection
        }
    }
    
    // This sends an update to via a non-optional progress block
    func updateProgress(connected: Bool) {
        let complete = (self.status == SendStatus.Complete) ? true : false
        if self.sendIndex <= 0 {
            self.updateBlock(0, connected, complete)
        }
        else {
            let percent =  Float(self.sendIndex) / Float(self.data.length)
            self.updateBlock(percent, connected, complete)
        }
    }
    
    // Delegate Methods
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            
            // Create a service with characteristics and add it to the manager
            let transChar = CBMutableCharacteristic(type: CBUUID(string: Constants.Bluetooth.CHARACTERISTIC_UUID), properties: .notify, value: nil, permissions: .readable)
            
            let service = CBMutableService(type: CBUUID(string: Constants.Bluetooth.SERVICE_UUID), primary: true)
            service.characteristics = [transChar]
            
            self.characteristic = transChar
            
            manager.add(service)
            
            // Now advertise it to the world
            let dictionary = [CBAdvertisementDataServiceUUIDsKey : [CBUUID(string: Constants.Bluetooth.SERVICE_UUID)]]
            manager.startAdvertising(dictionary)
        }
    }
    
    /** Catch when someone subscribes to our characteristic, then start sending them data */
    func peripheralManager(peripheral: CBPeripheralManager!, central: CBCentral!, didSubscribeToCharacteristic characteristic: CBCharacteristic!) {
        self.sendIndex = 0
        self.status = SendStatus.ReadyToStart
        updateProgress(connected: true)
        send()
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        self.status = .NotReady
        updateProgress(connected: false)
    }
    
    /** This callback comes in when the PeripheralManager is ready to send the next chunk of data.
    *  This is to ensure that packets will arrive in the order they are sent
    */
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        send()
    }
    
    // Send based on whatever was last sent successfully. If we reach the end, then
    func send() {
        if self.status == SendStatus.NotReady {
            return
        }
        if self.status == SendStatus.Complete {
            
        }
        
        if let
            characteristic = self.characteristic
        {
            repeat {
                if self.status == .ReadyToStart { // Before starting, send the length of the data
                    if let size = Constants.Bluetooth.MessageSize.appendingFormat("%ld", self.data.length).data(using: String.Encoding.utf8, allowLossyConversion: false) {
                        let success = self.manager.updateValue(size, for: characteristic, onSubscribedCentrals: nil)
                        if success == true {
                            self.status = SendStatus.InProgress
                            updateProgress(connected: true)
                        }
                        else {
                            break
                        }
                    }
                }
                // Send a done transfer message
                if self.sendIndex >= data.length,
                    let eom = Constants.Bluetooth.EndOfMessage.data(using: String.Encoding.utf8, allowLossyConversion: false) {
                    if manager.updateValue(eom, for: characteristic, onSubscribedCentrals: nil) {
                        self.status = SendStatus.Complete
                        updateProgress(connected: true)
                        stopAll()
                    }
                    break
                }
                else { // this is the only part that transmits the actual data
                    let numBytesToSend = min(Constants.Bluetooth.MAX_SIZE, data.length-self.sendIndex)
                    let dataToSend = data.subdata(with: NSMakeRange(self.sendIndex, numBytesToSend))
                    let success = manager.updateValue(dataToSend, for: characteristic, onSubscribedCentrals: nil)
                    if success == true {
                        self.sendIndex += numBytesToSend
                        updateProgress(connected: true)
                    }
                    else {
                        break
                    }
                }
            } while true
        }
    }
    
    func stopAll() {
        self.manager.stopAdvertising()
        self.manager.removeAllServices()

    }
    
    deinit {
        stopAll()
    }
    
}
