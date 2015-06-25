//
//  BluetoothFileSender.swift
//  UnfoldingWord
//
//  Created by David Solberg on 6/22/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

import Foundation
import CoreBluetooth

@objc final class BluetoothFileSender : NSObject, CBPeripheralManagerDelegate {
    
    // Percent complete is an Int from 0 to 100. 100 indicates that the transfer is complete.
    typealias SendUpdateBlock = (percentComplete: Int, connected : Bool) -> ()
    
    lazy var manager : CBPeripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    var characteristic : CBMutableCharacteristic?
    var data : NSData
    var sendIndex : Int = 0
    var connected : Bool = false
    let updateBlock : SendUpdateBlock
    
    init(dataToSend: NSData, updateBlock: SendUpdateBlock) {
        self.data = dataToSend
        self.updateBlock = updateBlock
        super.init()
        if self.manager.state == CBPeripheralManagerState.Resetting {
            println("Resetting. Executing the if statement should lazy initialize")
            self.sendIndex = -1 // just to ensure that the manager is lazy initialized in a release build
        }
    }
    
    // Delegate Methods
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager!) {
        
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
    
    /** Catch when someone subscribes to our characteristic, then start sending them data
    */
    func peripheralManager(peripheral: CBPeripheralManager!, central: CBCentral!, didSubscribeToCharacteristic characteristic: CBCharacteristic!) {
        println("Subscribed. start sending")
        self.sendIndex = 0
        self.connected = true
        send()
    }
    
    func peripheralManager(peripheral: CBPeripheralManager!, central: CBCentral!, didUnsubscribeFromCharacteristic characteristic: CBCharacteristic!) {
        println("unsubscribed")
        self.connected = false
    }
    
    /** This callback comes in when the PeripheralManager is ready to send the next chunk of data.
    *  This is to ensure that packets will arrive in the order they are sent
    */
    func peripheralManagerIsReadyToUpdateSubscribers(peripheral: CBPeripheralManager!) {
        // Don't reset the sendIndex because this method gets called every time the pipeline has empty space.
        send()
    }
    
    // Send based on whatever was last sent successfully. If we reach the end, then
    func send() {
        if self.sendIndex < 0 {
            return
        }
        
        if let
            characteristic = self.characteristic
        {
            do {
                if (self.sendIndex >= data.length) { // Done transferring data
                    let eom = Constants.Bluetooth.EndOfMessage.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
                    if manager.updateValue(eom, forCharacteristic: characteristic, onSubscribedCentrals: nil) {
                        break;
                    }
                }
                else {
                    let numBytesToSend = min(Constants.Bluetooth.MAX_SIZE, data.length-self.sendIndex)
                    let dataToSend = data.subdataWithRange(NSMakeRange(self.sendIndex, numBytesToSend))
                    let success = manager.updateValue(dataToSend, forCharacteristic: characteristic, onSubscribedCentrals: nil)
                    if success == true {
                        self.sendIndex += numBytesToSend
                    }
                    else {
                        break;
                    }
                }
            } while true
        }
    }
    
    deinit {
        self.manager.stopAdvertising()
    }
    
}