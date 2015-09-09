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
    
    init(dataToSend: NSData, updateBlock: FileUpdateBlock) {
        self.data = dataToSend
        self.updateBlock = updateBlock
        super.init()
        if self.manager.state == CBPeripheralManagerState.Resetting {
            self.sendIndex = -1 // to ensure that the manager is lazy initialized and indicate there is no connection
        }
    }
    
    // This sends an update to via a non-optional progress block
    func updateProgress(connected: Bool) {
        let complete = (self.status == SendStatus.Complete) ? true : false
        if self.sendIndex <= 0 {
            self.updateBlock(percentComplete: 0, connected: connected, complete: complete)
        }
        else {
            let percent =  Float(self.sendIndex) / Float(self.data.length)
            self.updateBlock(percentComplete: percent, connected: connected, complete: complete)
        }
    }
    
    // Delegate Methods
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        
        if peripheral.state == CBPeripheralManagerState.PoweredOn {
            
            // Create a service with characteristics and add it to the manager
            let transChar = CBMutableCharacteristic(type: CBUUID(string: Constants.Bluetooth.CHARACTERISTIC_UUID), properties: CBCharacteristicProperties.Notify, value: nil, permissions: CBAttributePermissions.Readable)
            
            let service = CBMutableService(type: CBUUID(string: Constants.Bluetooth.SERVICE_UUID), primary: true)
            service.characteristics = [transChar]
            
            self.characteristic = transChar
            
            manager.addService(service)
            
            // Now advertise it to the world
            let dictionary = [CBAdvertisementDataServiceUUIDsKey : [CBUUID(string: Constants.Bluetooth.SERVICE_UUID)]]
            manager.startAdvertising(dictionary)
        }
    }
    
    /** Catch when someone subscribes to our characteristic, then start sending them data */
    func peripheralManager(peripheral: CBPeripheralManager, central: CBCentral, didSubscribeToCharacteristic characteristic: CBCharacteristic) {
        self.sendIndex = 0
        self.status = SendStatus.ReadyToStart
        updateProgress(true)
        send()
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFromCharacteristic characteristic: CBCharacteristic) {
        self.status = SendStatus.NotReady
        updateProgress(false)
    }
    
    /** This callback comes in when the PeripheralManager is ready to send the next chunk of data.
    *  This is to ensure that packets will arrive in the order they are sent
    */
    func peripheralManagerIsReadyToUpdateSubscribers(peripheral: CBPeripheralManager) {
        // Don't reset the sendIndex because this method gets called every time the pipeline has empty space.
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
                if self.status == SendStatus.ReadyToStart { // Before starting, send the length of the data
                    if let size = Constants.Bluetooth.MessageSize.stringByAppendingFormat("%ld", self.data.length).dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                        let success = self.manager.updateValue(size, forCharacteristic: characteristic, onSubscribedCentrals: nil)
                        if success == true {
                            self.status = SendStatus.InProgress
                            updateProgress(true)
                        }
                        else {
                            break
                        }
                    }
                }
                
                if self.sendIndex >= data.length { // Send a done transfer message
                    let eom = Constants.Bluetooth.EndOfMessage.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
                    if manager.updateValue(eom!, forCharacteristic: characteristic, onSubscribedCentrals: nil) {
                        self.status = SendStatus.Complete
                        updateProgress(true)
                        stopAll()
                    }
                    break
                }
                else { // this is the only part that transmits the actual data
                    let numBytesToSend = min(Constants.Bluetooth.MAX_SIZE, data.length-self.sendIndex)
                    let dataToSend = data.subdataWithRange(NSMakeRange(self.sendIndex, numBytesToSend))
                    let success = manager.updateValue(dataToSend, forCharacteristic: characteristic, onSubscribedCentrals: nil)
                    if success == true {
                        self.sendIndex += numBytesToSend
                        updateProgress(true)
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