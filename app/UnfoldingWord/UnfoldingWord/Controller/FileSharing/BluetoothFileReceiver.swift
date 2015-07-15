//
//  BluetoothFileReceiver.swift
//  UnfoldingWord
//
//  Created by David Solberg on 6/22/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

import Foundation
import CoreBluetooth

@objc final class BluetoothFileReceiver : NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    lazy var manager : CBCentralManager = CBCentralManager(delegate: self, queue: nil)
    var discoveredPeripheral : CBPeripheral? = nil
    var receivedData : NSMutableData = NSMutableData()
    var finished : Bool = false
    var totalDataByteSize : Int = 0
    let updateBlock : FileUpdateBlock
    
    init(updateBlock : FileUpdateBlock) {
        self.updateBlock = updateBlock
        super.init()
        
        // This lazy loads the manager, which will in turn power on bluetooth, which activates Step 1.
        if self.manager.state == CBCentralManagerState.Resetting {
            self.receivedData = NSMutableData()
        }
    }
    
    // This sends an update to via a non-optional progress block
    func updateProgress(connected: Bool) {
        if self.receivedData.length == 0 && self.finished == false {
            self.updateBlock(percentComplete: 0, connected: connected, complete: self.finished)
        }
        else {
            let percent =  Float(self.receivedData.length) / Float(self.totalDataByteSize)
            self.updateBlock(percentComplete: percent, connected: connected, complete: self.finished)
        }
    }
    
    // Step 1: As soon as bluetooth powers up, start scanning for a device to get our book
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        if central.state == CBCentralManagerState.PoweredOn {
            scanForUnfoldingWordService()
        }
    }
    
    // Step 2: Start scanning for devices that have the service we want
    func scanForUnfoldingWordService() {
        self.finished = false
        self.manager.scanForPeripheralsWithServices([CBUUID(string: Constants.Bluetooth.SERVICE_UUID)], options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
    }
    
    // Step 3: Discovered the peripheral with the correct service, now try to connect to it.
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        if RSSI.integerValue < -70 { // If the signal's too low, then don't even try.
            println("Invalid RSSI \(RSSI)")
            return
        }
        
        // Directly connect to any peripheral we find, and throw away the old one.
        if let existingPeripheral = self.discoveredPeripheral {
            if existingPeripheral != peripheral {
                self.discoveredPeripheral = peripheral
                self.manager.connectPeripheral(peripheral, options: nil)
            }
        }
        else {
            self.discoveredPeripheral = peripheral
            self.manager.connectPeripheral(peripheral, options: nil)
        }
    }
    
    func centralManager(central: CBCentralManager!, didFailToConnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        println("\(error)")
        updateProgress(false)
        disconnectAll()
    }
    
    // Step 4: We connected, now send a request to get the services we want
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        // We found a peripheral that wants to send us data. Stop looking and discover services on the peripheral
        self.manager.stopScan()
        self.receivedData = NSMutableData()
        peripheral.delegate = self
        peripheral.discoverServices([CBUUID(string: Constants.Bluetooth.SERVICE_UUID)])
        updateProgress(true)
    }
    
    // Step 5: We got the services, now send a request to get the service characteristics that we want
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        if let error = error {
            disconnectAll()
            updateProgress(false)
        }
        else {
            for service in peripheral.services {
                let serv = service as! CBService
                peripheral.discoverCharacteristics([CBUUID(string: Constants.Bluetooth.CHARACTERISTIC_UUID)], forService: serv)
            }
        }
    }
    
    // Step 6: We got the characteristics we wanted, now tell it we want that characteristic (in this case, we're asking for the data to be sent to us)
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
        if let error = error {
            disconnectAll()
        }
        else {
            for characteristic in service.characteristics {
                let char = characteristic as! CBCharacteristic
                if char.UUID == CBUUID(string: Constants.Bluetooth.CHARACTERISTIC_UUID) {
                    peripheral.setNotifyValue(true, forCharacteristic: char)
                    updateProgress(true)
                }
            }
        }
    }
    
    // Step 7: Receive the data. This comes in little chunks, so we just keep adding data to our data object until we encounter an end-of-line
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        if let error = error {
            return
        }
        else if self.finished == true {
            return
        }
        else {
            // If we can make the data into a string, check to see whether it matches any control text at the start or end of the data file.
            if let dataAsString = NSString(data: characteristic.value, encoding: NSUTF8StringEncoding) {
                if dataAsString == Constants.Bluetooth.EndOfMessage {
                    self.finished = true
                    peripheral.setNotifyValue(false, forCharacteristic: characteristic)
                    self.manager.cancelPeripheralConnection(peripheral)
                    updateProgress(false)
                    return
                }
                // If we don't have any data yet, then check whether we're getting a string that tells the file size.
                if self.receivedData.length == 0 && dataAsString.rangeOfString(Constants.Bluetooth.MessageSize).location != NSNotFound {
                    let sizeString : NSString = dataAsString.stringByReplacingOccurrencesOfString(Constants.Bluetooth.MessageSize, withString: "")
                    self.totalDataByteSize = sizeString.integerValue
                    updateProgress(true)
                    return
                }
            }
            
            // If we passed through the start or end markers of the file, we have actual file data.
            self.receivedData.appendData(characteristic.value)
            updateProgress(true)
        }
    }
    
    // If the sender canceled, then we should do something
    func peripheral(peripheral: CBPeripheral!, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        if let error = error {
            return
        }
        if characteristic.UUID == CBUUID(string: Constants.Bluetooth.CHARACTERISTIC_UUID)
            && characteristic.isNotifying == false {
                self.manager.cancelPeripheralConnection(peripheral)
                updateProgress(false)
                println("The sender must have canceled the connection.")
        }
    }
    
    // Go through all the peripheral's services, find our service, then go through its characteristics to find our characteristic, then tell it to bugger off (stop notifying us), then cancel the connection.
    func disconnectAll() {
        if let peripheral = self.discoveredPeripheral {
            
            // If we haven't found anything yet, then we have no connections.
            if peripheral.state == CBPeripheralState.Disconnected {
                return
            }
            
            // Cancel all subscriptions by winding through all the characteristics of all the services to find ours.
            // What a pretty pyramid!
            if let services = peripheral.services {
                for service in services {
                    if let characteristics = service.characteristics {
                        for characteristic in characteristics {
                            if let char : CBCharacteristic = characteristic as? CBCharacteristic {
                                if char.UUID == NSUUID(UUIDString: Constants.Bluetooth.CHARACTERISTIC_UUID) {
                                    if char.isNotifying {
                                        peripheral.setNotifyValue(false, forCharacteristic: char)
                                        return
                                    }
                                }
                            }
                        }
                    }
                }
            }
            self.manager.cancelPeripheralConnection(peripheral)
        }
    }
    
    // Okay, we got disconnected. If we finished, then good. Otherwise start looking again
    func centralManager(central: CBCentralManager!, didDisconnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        self.discoveredPeripheral = nil

        if self.finished == false {
            self.updateProgress(false)
            scanForUnfoldingWordService()
        }
    }
    
    deinit {
        self.manager.stopScan()
        if let connection = self.discoveredPeripheral {
            self.manager.cancelPeripheralConnection(connection)
        }

    }
}