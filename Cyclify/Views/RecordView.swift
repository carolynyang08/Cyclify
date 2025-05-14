//
//  RecordView.swift
//  Cyclify
//
//  Created by Carolyn Yang on 3/29/25.
//

import SwiftUI
import SwiftData

struct AlertBadge: View {
    let alertType: AlertType
    let intensity: Int
    
    var body: some View {
        HStack(spacing: 6) {
            VStack(alignment: .leading, spacing: 2) {
                Text(alertType.name)
                    .font(.caption)
                    .fontWeight(.bold)
                
                Text(intensityDescription(intensity))
                    .font(.caption2)
                    .foregroundColor(colorForIntensity(intensity))
            }
        }
        .padding(8)
        .background(Color.black.opacity(0.7))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(colorForIntensity(intensity).opacity(0.5), lineWidth: 1)
        )
    }
    

    
    private func colorForIntensity(_ intensity: Int) -> Color {
        if intensity >= 90 {
            return .red
        } else if intensity >= 70 {
            return .orange
        } else if intensity >= 50 {
            return .yellow
        } else {
            return .green
        }
    }
    
    private func intensityDescription(_ intensity: Int) -> String {
        if intensity >= 90 {
            return "Critical (\(intensity)%)"
        } else if intensity >= 70 {
            return "High (\(intensity)%)"
        } else if intensity >= 50 {
            return "Medium (\(intensity)%)"
        } else {
            return "Low (\(intensity)%)"
        }
    }
}

struct RecordView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var users:[UserModel]
    @ObservedObject var watchManager = WatchConnectivityManager.shared
    @ObservedObject var bluetoothManager: BluetoothManager
    
    @State private var currentRide: Ride? = nil
    @State private var isRiding = false
    @State private var watchConnected = false
    @State private var isWatchAppInstalled = false
    @State private var isWatchWorkoutActive = false
    @State private var showWatchAlert = false
    @State private var currentAlert: RideAlert? = nil
    @State private var alertDisplayTimer: Timer? = nil

    
    let customCyan = Color(red: 145 / 255, green: 255 / 255, blue: 255 / 255)

    var currentUser: UserModel? {
        users.first
    }


    private func startAlertDisplayTimer() {
        alertDisplayTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            if isRiding {
                if let latestAlert = bluetoothManager.bufferedAlerts.max(by: { $0.timestamp < $1.timestamp }),
                   latestAlert.id != currentAlert?.id {

                    currentAlert = latestAlert
                    let thisAlertID = latestAlert.id

                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        if currentAlert?.id == thisAlertID {
                            currentAlert = nil
                        }
                    }
                }
            }
        }
    }


    
    private func stopAlertDisplayTimer() {
        alertDisplayTimer?.invalidate()
        alertDisplayTimer = nil
        currentAlert = nil
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("Get Ready to Ride!")
                    .font(.title)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 15)
                    .foregroundColor(customCyan)
                    .padding(.top, 40)

                Image("ride")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 400)
                    .cornerRadius(16)

                Spacer().frame(height: 30)
                
                // Watch connection status
                HStack {
                    Image(systemName: watchConnected ? "applewatch.radiowaves.left.and.right" : "applewatch.slash")
                        .foregroundColor(watchConnected ? .green : .red)
                        .font(.title2)
                    
                    Text(watchConnected ? "Apple Watch Connected" : "Apple Watch Not Connected")
                        .foregroundColor(.white)
                }
                .padding(.bottom, 20)

                if isRiding && isWatchWorkoutActive {
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                            .font(.title3)
                        
                        Text("Workout active on Apple Watch")
                            .foregroundColor(.green)
                    }
                    .padding(.bottom, 10)
                }
                
                // Display current alert
                if let alert = currentAlert, isRiding {
                    let alertTypeIndex = alert.type - 1
                      if  alertTypeIndex >= 0 && alertTypeIndex < AlertType.allCases.count {
                        let alertType = AlertType.allCases[alertTypeIndex]
                        
                        HStack(spacing: 6) {
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(alertType.name)
                                    .font(.headline)
                                    .fontWeight(.bold)
                                
                                Text(alertType.message(forIntensity: alert.intensity))
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            
                            Spacer()
                            
                            Text("\(alert.intensity)%")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(colorForIntensity(alert.intensity))
                        }
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(colorForIntensity(alert.intensity).opacity(0.5), lineWidth: 1)
                        )
                        .padding(.horizontal)
                        .transition(.opacity)
                        .animation(.easeInOut, value: currentAlert != nil)
                    }
                }

                Text("Ensure proper setup for a seamless ride")
                    .font(.title3)
                    .foregroundColor(.white)
                    .padding(.bottom, 40)

                Button(action: {
                    isRiding.toggle()

                    if isRiding {
                        let newRide = Ride(startTime: Date())
                        print("Ride started — currentRide ID: \(newRide.id)")

                        if let user = currentUser {
                            user.rides.append(newRide)
                            newRide.user = user
                        }

                        modelContext.insert(newRide)
                        bluetoothManager.currentRide = newRide
                        bluetoothManager.modelContext = modelContext
                        currentRide = newRide

                        try? modelContext.save()
                        
                        bluetoothManager.startRide()
                        bluetoothManager.sendRideControl("START")
                        
                        // Start alert display timer
                        startAlertDisplayTimer()
                        
                        // Start workout on Apple Watch if available
                        let watchManager = WatchConnectivityManager.shared
                        watchManager.modelContext = modelContext
                        watchManager.startWorkoutIfAvailable(rideId: newRide.id) { success in
                            DispatchQueue.main.async {
                                self.isWatchWorkoutActive = success
                                if !success {
                                    self.showWatchAlert = true
                                }
                            }
                        }

                        
                        if watchConnected && isWatchAppInstalled && !isWatchWorkoutActive {
                            showWatchAlert = true
                        }

                    } else {
                        bluetoothManager.stopRide()
                        bluetoothManager.sendRideControl("STOP")
                        currentRide?.endTime = Date()
                        
                        // Stop alert display timer
                        stopAlertDisplayTimer()
                        
                        // Stop workout on Apple Watch
                        if isWatchWorkoutActive {
                            WatchConnectivityManager.shared.stopWorkout()
                            isWatchWorkoutActive = false
                        }

                        if let ride = currentRide {
                            print("Buffered Sensor Readings:")
                            for reading in bluetoothManager.bufferedReadings {
                                print("\(reading.timestamp): \(reading.sensors)")
                                reading.ride = ride
                                ride.sensorData.append(reading)
                                modelContext.insert(reading)
                            }
                            
                            print("Buffered Alert Readings:")
                            for alert in bluetoothManager.bufferedAlerts {
                                alert.ride = ride
                                ride.alerts.append(alert)
                                modelContext.insert(alert)
                            }

                            do {
                                try modelContext.save()
                                print("Saved \(bluetoothManager.bufferedReadings.count) readings to database")
                                print("Saved \(bluetoothManager.bufferedAlerts.count) alerts to database")
                            } catch {
                                print("Failed to save readings: \(error)")
                                print("Failed to save alerts: \(error)")
                            }

                            bluetoothManager.bufferedReadings.removeAll()
                            bluetoothManager.bufferedAlerts.removeAll()
                            currentAlert = nil
                        }

                        currentRide = nil
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(customCyan)
                            .frame(width: 100, height: 100)

                        VStack {
                            Image(systemName: isRiding ? "stop.fill" : "play.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 24, weight: .bold))
                            Text(isRiding ? "FINISH" : "START")
                                .foregroundColor(.white)
                                .font(.footnote)
                                .fontWeight(.bold)
                        }
                    }
                }

                Spacer()
            }
        }
        .onAppear {
            // Check watch connection status
            let watchManager = WatchConnectivityManager.shared
            watchConnected = watchManager.isReachable
            isWatchAppInstalled = watchManager.isWatchAppInstalled
        }
        .onDisappear {
            stopAlertDisplayTimer()
        }
        .onChange(of: watchManager.workoutStartFailed) { failed in
            if failed {
                showWatchAlert = true
            }
        }
        .onChange(of: WatchConnectivityManager.shared.isReachable) { newValue in
            watchConnected = newValue
        }
        .onChange(of: WatchConnectivityManager.shared.isWatchAppInstalled) { newValue in
            isWatchAppInstalled = newValue
        }

    }
    
    private func colorForIntensity(_ intensity: Int) -> Color {
        if intensity >= 90 {
            return .red
        } else if intensity >= 70 {
            return .orange
        } else if intensity >= 50 {
            return .yellow
        } else {
            return .green
        }
    }
}

