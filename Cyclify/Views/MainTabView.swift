//
//  MainTabView.swift
//  Cyclify
//
//  Created by Carolyn Yang on 3/29/25.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @ObservedObject var bluetoothManager: BluetoothManager
    @ObservedObject var calibrationModel: CalibrationModel


    var body: some View {
        TabView {
            MainView(bluetoothManager: bluetoothManager, calibrationModel: calibrationModel)

                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }

            RecordView(bluetoothManager: bluetoothManager)
                .tabItem {
                    Image(systemName: "record.circle")
                    Text("Record")
                }

            ProfileView()
                .tabItem {
                    Image(systemName: "person")
                    Text("You")
                }
        }
        .accentColor(.white)
    }
}


