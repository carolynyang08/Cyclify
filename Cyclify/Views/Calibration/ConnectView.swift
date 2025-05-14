//
//  ConnectView.swift
//  Cyclify
//
//  Created by Carolyn Yang on 3/15/25.
//

import SwiftUI
import SwiftData
import CoreBluetooth

struct ConnectView: View {
    var userModel: UserModel
    @ObservedObject var service: BluetoothManager
    @ObservedObject var calibrationModel: CalibrationModel
    @Environment(\.presentationMode) var presentationMode
    
    let customCyan = Color(red: 145 / 255, green: 255 / 255, blue: 255 / 255)
    let lightBlue = Color(red: 0.0, green: 0.67, blue: 1.0)
    let darkPurple = Color(red: 0.5, green: 0.0, blue: 1.0)
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            Image("cyclify-bike")
                .resizable()
                .scaledToFit()
                .frame(width: 250, height: 250)
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [customCyan, darkPurple]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .position(x: 40, y: 60)
            
            Image("cyclify-bike")
                .resizable()
                .scaledToFit()
                .frame(width: 250, height: 250)
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [customCyan, darkPurple]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .position(x: UIScreen.main.bounds.width - 30, y: UIScreen.main.bounds.height - 150)
            
  
            VStack(spacing: 24) {
                Text("Device Pairing")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 40)
                
                HStack(spacing: 12) {
                    if service.peripheralStatus == .scanning {
                        Circle()
                            .fill(customCyan)
                            .frame(width: 12, height: 12)
                            .opacity(0.8)
                            .animation(Animation.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: service.peripheralStatus)
                    }
                    
                    Text(service.peripheralStatus.rawValue.capitalized)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(statusColor)
                }
                .padding(.vertical, 8)
                
     
                VStack(spacing: 16) {
                    // Scan button
                    Button(action: {
                        print("Scan button pressed")
                        service.scanForPeripherals()
                    }) {
                        HStack {
                            Image(systemName: "bluetooth.circle.fill")
                                .font(.title2)
                            Text("Scan for Devices")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    service.peripheralStatus == .scanning ?
                                        Color.gray.opacity(0.5) : customCyan,
                                    service.peripheralStatus == .scanning ?
                                        Color.gray.opacity(0.5) : lightBlue
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(color: service.peripheralStatus == .scanning ? .clear : customCyan.opacity(0.5), radius: 5, x: 0, y: 2)
                    }
                    .disabled(service.peripheralStatus == .scanning || service.peripheralStatus == .connected || service.peripheralStatus == .connecting)
                    
                    // Stop Scanning button
                    Button(action: {
                        print("Stop scanning button pressed")
                        service.stopScanning()
                    }) {
                        HStack {
                            Image(systemName: "stop.circle.fill")
                                .font(.title2)
                            Text("Stop Scanning")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    service.peripheralStatus == .scanning ?
                                        Color(red: 1.0, green: 0.3, blue: 0.3) : Color.gray.opacity(0.5),
                                    service.peripheralStatus == .scanning ?
                                        darkPurple : Color.gray.opacity(0.5)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(color: service.peripheralStatus == .scanning ? Color.red.opacity(0.5) : .clear, radius: 5, x: 0, y: 2)
                    }
                    .disabled(service.peripheralStatus != .scanning)
                    
   
                    Button(action: {
                        print("Disconnect button pressed")
                        service.disconnect()
                    }) {
                        HStack {
                            Image(systemName: "link.badge.minus")
                                .font(.title2)
                            Text("Disconnect")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    service.peripheralStatus == .connected ?
                                        Color(red: 1.0, green: 0.3, blue: 0.3) : Color.gray.opacity(0.5),
                                    service.peripheralStatus == .connected ?
                                        darkPurple : Color.gray.opacity(0.5)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(color: service.peripheralStatus == .connected ? Color.red.opacity(0.5) : .clear, radius: 5, x: 0, y: 2)
                    }
                    .disabled(service.peripheralStatus != .connected)
                }
                .padding(.horizontal, 24)
                
                // List of discovered devices
                VStack(alignment: .leading, spacing: 12) {
                    if !service.discoveredPeripherals.isEmpty {
                        Text("Discovered Devices:")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.leading, 8)
                            .padding(.top, 8)
                        
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(service.discoveredPeripherals, id: \.identifier) { peripheral in
                                    Button(action: {
                                        service.connect(to: peripheral)
                                    }) {
                                        HStack {
                                            Image(systemName: "wave.3.right.circle.fill")
                                                .foregroundColor(customCyan)
                                                .font(.title3)
                                            
                                            Text(peripheral.name ?? "Unknown Device")
                                                .foregroundColor(.white)
                                                .font(.headline)
                                            
                                            Spacer()
                                            
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(customCyan)
                                                .font(.body)
                                        }
                                        .padding(.vertical, 12)
                                        .padding(.horizontal, 16)
                                        .background(Color(white: 0.15))
                                        .cornerRadius(12)
                                    }
                                    .disabled(service.peripheralStatus == .connected || service.peripheralStatus == .connecting)
                                }
                            }
                            .padding(.horizontal, 8)
                        }
                        .frame(height: 200)
                    } else if service.peripheralStatus == .scanning {
                        HStack {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: customCyan))
                            
                            Text("Scanning for devices...")
                                .foregroundColor(customCyan)
                                .padding(.leading, 8)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                    }
                }
                .padding(.horizontal, 16)
                
                // Calibration button
                if service.peripheralStatus == .connected {
                    NavigationLink(destination: CalibrationStart(userModel: userModel, bluetoothManager: service, calibrationModel: calibrationModel)) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title2)
                            Text("Proceed to Calibration")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [customCyan, darkPurple]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(color: customCyan.opacity(0.5), radius: 5, x: 0, y: 2)
                        .padding(.horizontal, 24)
                    }
                }
                
                Spacer()
            }
            .padding(.top, 20)
        }
        .navigationTitle("")
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                Image(systemName: "chevron.left")
                    .foregroundColor(.white)
                Text("Back")
                    .foregroundColor(.white)
                    .fontWeight(.medium)
            }
        })
        .onChange(of: service.peripheralStatus) { newStatus in
            if newStatus == .connected {
                print("Peripheral connected, sending weight: \(userModel.weight) and level: \(userModel.trainingLevel)")
                service.sendWeight(Int(userModel.weight))
                service.sendLevel(userModel.trainingLevel)
            }
        }
    }
    
    private var statusColor: Color {
        switch service.peripheralStatus {
        case .connected:
            return Color.green
        case .disconnected, .error:
            return Color.red
        case .scanning:
            return customCyan
        case .connecting:
            return Color.orange
        }
    }
}

#Preview {
    let user = UserModel(
        email: "preview@example.com",
        firstName: "Preview",
        lastName: "User",
        weight: 160,
        weightUnit: "LB",
        heightFeet: 5,
        heightInches: 11
    )
    
    return ConnectView(
        userModel: user,
        service: BluetoothManager(),
        calibrationModel: CalibrationModel()
    )
}
