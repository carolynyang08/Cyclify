//
//  ContentView.swift
//  Cyclify
//
//  Created by Carolyn Yang on 4/20/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    
    var body: some View {
        VStack {
            if workoutManager.isWorkoutActive {
                WorkoutView()
            } else {
                ProgressView("Waiting for workout...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
                
                Text("Start a ride on your iPhone to begin tracking")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
    }

}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(WorkoutManager.shared)
    }
}
