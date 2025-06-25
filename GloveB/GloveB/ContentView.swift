//
//  ContentView.swift
//  GloveB
//
//  Created by Raaju Pahlowan on 24/6/25.
//

import SwiftUI

import SwiftUI

struct ContentView: View {
    @StateObject var bluetoothManager = BluetoothManager()
    @State private var isScanning = false

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text("Tactile Glove")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .padding(.top, 20)

                Spacer().frame(height: 40)

                Text("🔍")
                    .padding()
                    .frame(maxWidth: .infinity)
                    //.background(Color.blue.opacity(0.2))
                    .cornerRadius(10)
                    .font(.headline)

                Button(action: {
                    isScanning = true
                    bluetoothManager.startScanning()
                }) {
                    Text(isScanning
                         ? (bluetoothManager.discoveredPeripherals.isEmpty ? "Searching.." : "Search Again")
                         : "Start Searching")
                        .frame(maxWidth: .infinity)
                        .frame(height: UIScreen.main.bounds.height / 6)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .font(.title2)
                }

                List {
                    ForEach(bluetoothManager.discoveredPeripherals, id: \..identifier) { peripheral in
                        VStack(alignment: .leading) {
                            Text(peripheral.name ?? "Unnamed Device")
                                .font(.headline)
                            Button(action: {
                                bluetoothManager.connect(to: peripheral)
                            }) {
                                Text("Connect")
                                    .frame(maxWidth: .infinity)
                                    .frame(height: UIScreen.main.bounds.height / 6)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .font(.title2)
                            }
                        }
                        .padding(.vertical, 10)
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
            .navigationBarHidden(true)
        }
    }
}
