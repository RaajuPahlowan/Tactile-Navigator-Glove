//
//  ContentView.swift
//  GloveB
//
//  Created by Raaju Pahlowan on 24/6/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var bluetoothManager = BluetoothManager()

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Button("Start Scanning") {
                    bluetoothManager.startScanning()
                }
                .buttonStyle(.borderedProminent)

                List {
                    ForEach(bluetoothManager.discoveredPeripherals, id: \..identifier) { peripheral in
                        HStack {
                            Text(peripheral.name ?? "Unnamed Device")
                            Spacer()
                            Button("Connect") {
                                bluetoothManager.connect(to: peripheral)
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }

                if let connected = bluetoothManager.connectedPeripheral {
                    Text("✅ Connected to: \(connected.name ?? "Device")")
                        .foregroundColor(.green)
                        .padding(.top)
                }

                if let last = bluetoothManager.lastSpokenDistance {
                    Text("📏 Last: \(String(format: "%.1f", last)) feet")
                        .font(.headline)
                        .padding(.top)
                }
            }
            .padding()
            .navigationTitle("Tactile Glove")
        }
    }
}

