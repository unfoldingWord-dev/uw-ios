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
    
    @objc lazy var manager : CBCentralManager = CBCentralManager(delegate: self, queue: nil)
    @objc var discoveredPeripheral: CBPeripheral? = nil
    @objc var receivedData: NSMutableData = NSMutableData()
    @objc var finished: Bool = false
    @objc var totalDataByteSize: Int = 0
    @objc let updateBlock: FileUpdateBlock
    
    @objc init(updateBlock : @escaping FileUpdateBlock) {
        self.updateBlock = updateBlock
        super.init()
        // This lazy loads the manager, which will in turn power on bluetooth, which activates Step 1.
        if self.manager.state == .resetting {
            self.receivedData = NSMutableData()
        }
    }
    
    // This sends an update to via a non-optional progress block
    func updateProgress(connected: Bool) {
        if self.receivedData.length == 0 && self.finished == false {
            self.updateBlock(0, connected, self.finished)
        }
        else {
            let percent =  Float(self.receivedData.length) / Float(self.totalDataByteSize)
            self.updateBlock(percent, connected, self.finished)
        }
    }
    
    // Step 1: As soon as bluetooth powers up, start scanning for a device to get our book
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            scanForUnfoldingWordService()
        }
    }
    
    // Step 2: Start scanning for devices that have the service we want
    func scanForUnfoldingWordService() {
        self.finished = false
        self.manager.scanForPeripherals(withServices: [CBUUID(string: Constants.Bluetooth.SERVICE_UUID)], options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
    }
    // 'centralManager(_:didDiscover:advertisementData:rssi:)' of protocol 'CBCentralManagerDelegate'
    // Step 3: Discovered the peripheral with the correct service, now try to connect to it.
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if RSSI.intValue < -70 { // If the signal's too low, then don't even try.
            print("Invalid RSSI \(RSSI)")
            return
        }
        
        // Directly connect to any peripheral we find, and throw away the old one.
        if let existingPeripheral = self.discoveredPeripheral {
            if existingPeripheral != peripheral {
                self.discoveredPeripheral = peripheral
                self.manager.connect(peripheral, options: nil)
            }
        }
        else {
            self.discoveredPeripheral = peripheral
            self.manager.connect(peripheral, options: nil)
        }
    }
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("\(String(describing: error))")
        updateProgress(connected: false)
        disconnectAll()
    }
    
    // Step 4: We connected, now send a request to get the services we want
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        // We found a peripheral that wants to send us data. Stop looking and discover services on the peripheral
        self.manager.stopScan()
        self.receivedData = NSMutableData()
        peripheral.delegate = self
        peripheral.discoverServices([CBUUID(string: Constants.Bluetooth.SERVICE_UUID)])
        updateProgress(connected: true)
    }
    
    // Step 5: We got the services, now send a request to get the service characteristics that we want
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if error != nil {
            disconnectAll()
            updateProgress(connected: false)
        }
        else if let services = peripheral.services {
            for service in services {
                peripheral.discoverCharacteristics([CBUUID(string: Constants.Bluetooth.CHARACTERISTIC_UUID)], for: service)
            }
        }
    }

    // Step 6: We got the characteristics we wanted, now tell it we want that characteristic (in this case, we're asking for the data to be sent to us)
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if error != nil {
            disconnectAll()
        }
        else if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid == CBUUID(string: Constants.Bluetooth.CHARACTERISTIC_UUID) {
                    peripheral.setNotifyValue(true, for: characteristic)
                    updateProgress(connected: true)
                }
            }
        }
    }

    // Step 7: Receive the data. This comes in little chunks, so we just keep adding data to our data object until we encounter an end-of-line
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            return
        }
        else if self.finished == true {
            return
        }
        else {
            // If we can make the data into a string, check to see whether it matches any control text at the start or end of the data file.
            if let value = characteristic.value, let dataAsString = NSString(data: value, encoding: String.Encoding.utf8.rawValue) {
                if dataAsString as String == Constants.Bluetooth.EndOfMessage {
                    self.finished = true
                    peripheral.setNotifyValue(false, for: characteristic)
                    self.manager.cancelPeripheralConnection(peripheral)
                    updateProgress(connected: false)
                    return
                }
                // If we don't have any data yet, then check whether we're getting a string that tells the file size.
                if self.receivedData.length == 0 && dataAsString.range(of: Constants.Bluetooth.MessageSize).location != NSNotFound {
                    let sizeString : NSString = dataAsString.replacingOccurrences(of: Constants.Bluetooth.MessageSize, with: "") as NSString
                    self.totalDataByteSize = sizeString.integerValue
                    updateProgress(connected: true)
                    return
                }
            }
            
            // If we passed through the start or end markers of the file, we have actual file data.
            if let value = characteristic.value {
                self.receivedData.append(value)
            }
            updateProgress(connected: true)
        }
    }
    
    // If the sender canceled, then we should do something
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            return
        }
        if characteristic.uuid == CBUUID(string: Constants.Bluetooth.CHARACTERISTIC_UUID)
            && characteristic.isNotifying == false {
                self.manager.cancelPeripheralConnection(peripheral)
            updateProgress(connected: false)
                print("The sender must have canceled the connection.")
        }
    }
    
    // Go through all the peripheral's services, find our service, then go through its characteristics to find our characteristic, then tell it to bugger off (stop notifying us), then cancel the connection.
    func disconnectAll() {
        if let peripheral = self.discoveredPeripheral {
            
            // If we haven't found anything yet, then we have no connections.
            if peripheral.state == .disconnected {
                return
            }
            
            // Cancel all subscriptions by winding through all the characteristics of all the services to find ours.
            // What a pretty pyramid!
            if let services = peripheral.services {
                for service in services {
                    if let characteristics = service.characteristics {
                        for characteristic in characteristics {
                            if characteristic.uuid == CBUUID(string: Constants.Bluetooth.CHARACTERISTIC_UUID) {
                                if characteristic.isNotifying {
                                    peripheral.setNotifyValue(false, for: characteristic)
                                    return
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
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        self.discoveredPeripheral = nil

        if self.finished == false {
            self.updateProgress(connected: false)
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
