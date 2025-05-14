//
//  AppEntryPointView.swift
//  Cyclify
//
//  Created by Carolyn Yang on 3/30/25.
//

import SwiftUI
import SwiftData

struct AppEntryPointView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [UserModel]
    @State private var isRegistered = false

    var bluetoothManager: BluetoothManager
    var calibrationModel: CalibrationModel

    var body: some View {
        Group {
            if let user = users.first(where: { $0.isLoggedIn }) {
                MainTabView(
                    bluetoothManager: bluetoothManager,
                    calibrationModel: calibrationModel
                )
            } else {
                WelcomeView(
                    isRegistered: $isRegistered,
                    bluetoothManager: bluetoothManager,
                    calibrationModel: calibrationModel
                )
            }
        }
        .onAppear {
            bluetoothManager.modelContext = modelContext
        }
    }
}

