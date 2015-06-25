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
    var transmittedData : NSMutableData? = nil
    var finished : Bool = false
    
    override init() {
        super.init()
        if self.manager.state == CBCentralManagerState.Resetting {
            println("Resetting. Executing the if statement should lazy initialize")
            self.transmittedData = NSMutableData()
        }
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        if central.state == CBCentralManagerState.PoweredOn {
            scanForUnfoldingWordService()
        }
    }
    
    // Step 1: Start scanning for devices that have the service we want
    func scanForUnfoldingWordService() {
        self.manager.scanForPeripheralsWithServices([CBUUID(string: Constants.Bluetooth.SERVICE_UUID)], options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
    }
    
    // Step 2: Discover the peripheral, then try to connect to it.
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        if RSSI.integerValue < -75 {
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
        disconnectAll()
    }
    
    // Step 3: We connected, now send a request to get the services we want
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        // We found a peripheral that wants to send us data. Stop looking and discover services on the peripheral
        self.manager.stopScan()
        self.transmittedData = NSMutableData()
        self.finished = false
        peripheral.delegate = self
        peripheral.discoverServices([CBUUID(string: Constants.Bluetooth.SERVICE_UUID)])
    }
    
    // Step 4: We got the services, now send a request to get the service characteristics that we want
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        if let error = error {
            disconnectAll()
        }
        else {
            for service in peripheral.services {
                let serv = service as! CBService
                peripheral.discoverCharacteristics([CBUUID(string: Constants.Bluetooth.CHARACTERISTIC_UUID)], forService: serv)
            }
        }
    }
    
    // Step 5: We got the characteristics we wanted, now tell it we want that characteristic (in this case, we're asking for the data to be sent to us)
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
        if let error = error {
            disconnectAll()
        }
        else {
            for characteristic in service.characteristics {
                let char = characteristic as! CBCharacteristic
                if char.UUID == CBUUID(string: Constants.Bluetooth.CHARACTERISTIC_UUID) {
                    peripheral.setNotifyValue(true, forCharacteristic: char)
                }
            }
        }
    }
    
    // Step 6: Receive the data. This comes in little chunks, so we just keep adding data to our data object until we encounter an end-of-line
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        if let error = error {
            return
        }
        else {
            let possibleEOM = NSString(data: characteristic.value, encoding: NSUTF8StringEncoding)
            if possibleEOM == Constants.Bluetooth.EndOfMessage {
                self.finished = true
                peripheral.setNotifyValue(false, forCharacteristic: characteristic)
                self.manager.cancelPeripheralConnection(peripheral)
            }
            else {
                if let data = self.transmittedData {
                    data.appendData(characteristic.value)
                }
            }
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
                println("The sender must have canceled the connection.")
        }
    }
    
    // Go through all the peripheral's services, find our service, then go through its characteristics to find our characteristic, then tell it to bugger off, then cancel the connection.
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
            scanForUnfoldingWordService()
        }
        else {
            println("Done. Notify that we have the data.")
        }
    }
    
    deinit {
        self.manager.stopScan()
    }
}