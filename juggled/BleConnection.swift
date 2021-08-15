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
}

class BleConnection: NSObject, CBPeripheralDelegate, CBCentralManagerDelegate, ObservableObject {
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral!
    
    @Published var scannedDevices: [Device] = []
    @Published var connectedDevices: [Device] = []
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        centralManager.delegate = self
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == CBManagerState.poweredOn {
            central.scanForPeripherals(withServices: nil, options: nil)
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
    
    func connectDevice(device: Device) {
        centralManager.connect(device.peripheral, options: nil)
        self.connectedDevices.append(device)
    }
}
