//
//  BleConnection.swift
//  juggled
//
//  Created by Anna Scholtz on 2021-08-11.
//  Copyright © 2021 Anna Scholtz. All rights reserved.
//

import Foundation
import CoreBluetooth

struct Device: Hashable {
    var name: String
    var peripheral: CBPeripheral
    var characteristic: CBCharacteristic?
}

class BleConnection: NSObject, CBPeripheralDelegate, CBPeripheralManagerDelegate, CBCentralManagerDelegate, ObservableObject {
    private var centralManager: CBCentralManager!
    private var peripheralManager: CBPeripheralManager!
    
    private let SERVICE_UUID = CBUUID(string: "19B10010-E8F2-537E-4F6C-D104768A1214")
    private let WRITE_UUID = CBUUID(string: "19B10011-E8F2-537E-4F6C-D104768A1214")
    private let WRITE_PROPERTIES: CBCharacteristicProperties = .write
    private let WRITE_PERMISSIONS: CBAttributePermissions = .writeable
    
    @Published var scannedDevices: [Device] = []
    @Published var connectedDevices: [Device] = []
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        centralManager.delegate = self
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        peripheralManager.delegate = self
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == CBManagerState.poweredOn {
            central.scanForPeripherals(withServices: [SERVICE_UUID], options: nil)
        }
        else {
            print("Something went wrong with BLE")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let pname = peripheral.name {
            if !self.scannedDevices.contains(where: {$0.name == pname}) {
                self.scannedDevices.append(Device(name: pname, peripheral: peripheral))
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == CBManagerState.poweredOn {
            let serialService = CBMutableService(type: SERVICE_UUID, primary: true)
            let writeCharacteristics = CBMutableCharacteristic(type: WRITE_UUID,
                                             properties: WRITE_PROPERTIES, value: nil,
                                             permissions: WRITE_PERMISSIONS)
            serialService.characteristics = [writeCharacteristics]
            peripheralManager.add(serialService)
        } else {
            print("peripheralManager is off")
        }
    }
    
    func peripheral( _ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services! {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral( _ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics! {
            let characteristic = characteristic as CBCharacteristic
            if (characteristic.uuid.isEqual(WRITE_UUID)) {
                var device = self.connectedDevices.first(where: {$0.peripheral == peripheral})
                device?.characteristic = characteristic
            }
        }
    }
    
    func connectDevice(device: Device) {
        centralManager.connect(device.peripheral, options: nil)
        self.connectedDevices.append(device)
        device.peripheral.discoverServices(nil)
    }
    
    func sendMessage(device: Device, message: String) {
        device.peripheral.writeValue(message.data(using: .utf8)!, for: device.characteristic!, type: CBCharacteristicWriteType.withResponse)
    }
}
