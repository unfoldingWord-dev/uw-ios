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
    
    var manager : CBPeripheralManager?
    var characteristic : CBMutableCharacteristic?
    var data : NSData?
    var sendIndex : Int

    override init() {
        sendIndex = -1
        super.init()
        self.manager = CBPeripheralManager(delegate: self, queue: nil)
        
    }
    
    func send() {
        
        if self.sendIndex < 0 {
            return
        }
        
        if let
            data = self.data,
            manager = self.manager,
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
    
    // Delegate Methods
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager!) {
        
        if let manager = manager {
            if peripheral.state == CBPeripheralManagerState.PoweredOn {
                
                // Create a service with characteristics and add it to the manager
                let transChar = CBMutableCharacteristic(type: CBUUID(string: Constants.Bluetooth.CHARACTERISTIC_UUID), properties: CBCharacteristicProperties.Notify, value: nil, permissions: CBAttributePermissions.Readable)
                
                let service = CBMutableService(type: CBUUID(string: Constants.Bluetooth.SERVICE_UUID), primary: true)
                service.characteristics = [transChar]
                
                manager.addService(service)
                
                // Now advertise it to the world
                let dictionary = [CBAdvertisementDataServiceUUIDsKey : [CBUUID(string: Constants.Bluetooth.SERVICE_UUID)]]
                manager.startAdvertising(dictionary)
            }
        }
    }
    
    /** Catch when someone subscribes to our characteristic, then start sending them data
    */
    func peripheralManager(peripheral: CBPeripheralManager!, central: CBCentral!, didSubscribeToCharacteristic characteristic: CBCharacteristic!) {
        println("Subscribed. start sending")
        self.sendIndex = 0
        send()
    }
    
    func peripheralManager(peripheral: CBPeripheralManager!, central: CBCentral!, didUnsubscribeFromCharacteristic characteristic: CBCharacteristic!) {
        println("unsubscribed")
    }
    
    /** This callback comes in when the PeripheralManager is ready to send the next chunk of data.
    *  This is to ensure that packets will arrive in the order they are sent
    */
    func peripheralManagerIsReadyToUpdateSubscribers(peripheral: CBPeripheralManager!) {
        // Don't reset the sendIndex because this method gets called every time the pipeline has empty space.
        send()
    }
    
    deinit {
        self.manager?.stopAdvertising()
    }
    
}