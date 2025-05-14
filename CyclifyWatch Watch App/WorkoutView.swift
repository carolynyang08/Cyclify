//
//  WorkoutView.swift
//  Cyclify
//
//  Created by Carolyn Yang on 4/28/25.
//

import SwiftUI
import HealthKit

struct WorkoutView: View {
    @ObservedObject private var workoutManager = WorkoutManager.shared
    
    var body: some View {
        VStack {
            if workoutManager.isWorkoutActive {
                // Active workout view
                Text("Cycling")
                    .font(.headline)
                    .padding(.top)
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("HEART RATE")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("\(Int(workoutManager.heartRate)) BPM")
                            .font(.system(size: 24, weight: .semibold))
                    }
                    Spacer()
                    
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                        .font(.system(size: 24))
                        .scaleEffect(1.0 + 0.1 * sin(Double(Date().timeIntervalSince1970) * 3.0))
                        .animation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: UUID())
                }
                .padding()
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("CALORIES")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("\(Int(workoutManager.activeCalories)) KCAL")
                            .font(.system(size: 24, weight: .semibold))
                    }
                    Spacer()
                    
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                        .font(.system(size: 24))
                }
                .padding()
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("ELAPSED TIME")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(formattedElapsedTime)
                            .font(.system(size: 24, weight: .semibold))
                    }
                    Spacer()
                    
                    Image(systemName: "clock.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 24))
                }
                .padding()
                
                Spacer()
                
                Button(action: {
                    workoutManager.stopWorkout()
                }) {
                    Text("End Workout")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                }
                .padding()
            } else {
                // Waiting for workout view
                Text("Waiting for workout...")
                    .font(.headline)
                    .padding()
                
                Text("Start a ride on your iPhone to begin tracking")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .padding()
                
                Image(systemName: "bicycle")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
                    .padding()
                
                Spacer()
            
                Button(action: {
                    let testRideId = UUID()
                    workoutManager.startWorkout(rideId: testRideId)
                }) {
                    Text("Start Test Workout")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
        .onAppear {
            workoutManager.requestAuthorizationIfNeeded()
        }
    }
    
    private var formattedElapsedTime: String {
        let hours = Int(workoutManager.elapsedTime) / 3600
        let minutes = (Int(workoutManager.elapsedTime) % 3600) / 60
        let seconds = Int(workoutManager.elapsedTime) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

struct WorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutView()
    }
}
