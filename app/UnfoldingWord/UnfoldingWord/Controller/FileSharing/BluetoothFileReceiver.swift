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
    
    
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        if central.state == CBCentralManagerState.PoweredOn {
            scanForUnfoldingWordService()
        }
    }
    
    func scanForUnfoldingWordService() {
        self.manager.scanForPeripheralsWithServices([CBUUID(string: Constants.Bluetooth.SERVICE_UUID)], options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
    }
    
    // Step 1 : Discover the peripheral, then try to connect ot
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        if RSSI.integerValue > -15 || RSSI.integerValue < -35 { // want the value to be between -15 and -35
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
    }
    
    func centralManager(central: CBCentralManager!, didFailToConnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        println("\(error)")
        disconnectAll()
    }
    
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        // We found a peripheral that wants to send us data. Stop looking and discover services on the peripheral
        self.manager.stopScan()
        self.transmittedData = NSMutableData()
        self.finished = false
        peripheral.delegate = self
        peripheral.discoverServices([CBUUID(string: Constants.Bluetooth.SERVICE_UUID)])
    }
    
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
    
    func peripheral(peripheral: CBPeripheral!, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        if let error = error {
            return
        }
        if characteristic.UUID == CBUUID(string: Constants.Bluetooth.CHARACTERISTIC_UUID)
            && characteristic.isNotifying == false {
            self.manager.cancelPeripheralConnection(peripheral)
        }
    }
    
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
    
    func centralManager(central: CBCentralManager!, didDisconnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        self.discoveredPeripheral = nil
        scanForUnfoldingWordService()
    }
    
    deinit {
        self.manager.stopScan()
    }
}