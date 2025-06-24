//
//  BluetoothManager.swift
//  GloveB
//
//  Created by Raaju Pahlowan on 24/6/25.
//

import CoreBluetooth
import Foundation

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    var centralManager: CBCentralManager!
    var connectedPeripheral: CBPeripheral?
    var targetCharacteristic: CBCharacteristic?

    @Published var discoveredPeripherals: [CBPeripheral] = []
    @Published var lastSpokenDistance: Float? = nil

    let targetDeviceName = "ESP32_Ultrasonic"
    let SERVICE_UUID = CBUUID(string: "19b10000-e8f2-537e-4f6c-d104768a1214")
    let CHARACTERISTIC_UUID = CBUUID(string: "19b10001-e8f2-537e-4f6c-d104768a1214")

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("✅ Bluetooth is ON")
        } else {
            print("❌ Bluetooth not ready: \(central.state.rawValue)")
        }
    }

    func startScanning() {
        discoveredPeripherals.removeAll()
        centralManager.scanForPeripherals(withServices: nil, options: nil)
        print("🔍 Scanning for devices...")
    }

    func stopScanning() {
        centralManager.stopScan()
        print("⏹️ Scanning stopped.")
    }

    func connect(to peripheral: CBPeripheral) {
        centralManager.stopScan()
        connectedPeripheral = peripheral
        connectedPeripheral?.delegate = self
        centralManager.connect(peripheral, options: nil)
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let name = peripheral.name, name == targetDeviceName {
            print("📡 Found target device: \(name)")
            discoveredPeripherals.append(peripheral)
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("🔗 Connected to: \(peripheral.name ?? "Unnamed")")
        peripheral.discoverServices([SERVICE_UUID])
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services where service.uuid == SERVICE_UUID {
            peripheral.discoverCharacteristics([CHARACTERISTIC_UUID], for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for char in characteristics where char.uuid == CHARACTERISTIC_UUID {
            if char.properties.contains(.notify) || char.properties.contains(.read) {
                targetCharacteristic = char
                peripheral.setNotifyValue(true, for: char)
                print("✅ Subscribed to target characteristic")
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let data = characteristic.value else { return }

        let rawString = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        if let rawDistance = Float(rawString) {
            let distance = round(rawDistance * 10) / 10.0  // round to 1 decimal
            lastSpokenDistance = distance

            let spokenText = String(format: "Object detected at %.1f feet.", distance)
            print("📏 Speaking: \(spokenText)")
            TTSManager.shared.speak(text: spokenText)
        } else {
            print("❌ Invalid distance value: \(rawString)")
        }
    }
}
