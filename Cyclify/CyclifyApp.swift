//
//  CyclifyApp.swift
//  Cyclify
//
//  Created by Carolyn Yang on 2/24/25.
//

import SwiftUI
import SwiftData

@main
struct CyclifyApp: App {
    @StateObject var bluetoothManager = BluetoothManager()
    @StateObject var calibrationModel = CalibrationModel()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate


    
    init() {
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .black
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor = .white
    }
    
    var body: some Scene {
           WindowGroup {
               AppEntryPointView(
                   bluetoothManager: bluetoothManager,
                   calibrationModel: calibrationModel
               )
           }
           .modelContainer(for: [UserModel.self, Ride.self, SensorReading.self])
       }
    
}

