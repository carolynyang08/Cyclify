//
//  CyclifyApp.swift
//  Cyclify
//
//  Created by Carolyn Yang on 4/20/25.
//

import SwiftUI

@main
struct CyclifyWatch_Watch_AppApp: App {
    @StateObject private var workoutManager = WorkoutManager.shared
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
            .environmentObject(workoutManager)
        }
    }
    
    init() {
    }
}
