//
//  WatchConnectivityManager.swift
//  Cyclify
//
//  Created by Carolyn Yang on 4/19/25.
//

import Foundation
import WatchConnectivity
import SwiftData
import UIKit

enum WatchMessageType: String {
    case startWorkout
    case stopWorkout
    case workoutData
    case checkStatus
    case statusResponse
    case biometricUpdate
    case finalRideData
}

class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()
    
    @Published var isReachable = false
    @Published var watchStatus = "Not Connected"
    @Published var isWatchAppInstalled: Bool = false
    @Published var isWorkoutActive = false
    @Published var heartRate: Double = 0
    @Published var activeCalories: Double = 0
    @Published var elapsedTime: TimeInterval = 0
    @Published var workoutStartFailed: Bool = false
    
    private let session = WCSession.default
    var modelContext: ModelContext?
    private var statusCheckTimer: Timer?
    private var currentRideId: UUID?
    
    private override init() {
        super.init()
        
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()

            isWatchAppInstalled = session.isWatchAppInstalled
        }
    }
    
    func sendMessage(_ messageType: WatchMessageType, payload: [String: Any] = [:], replyHandler: (([String: Any]) -> Void)? = nil) {
        var message = payload
        message["type"] = messageType.rawValue
        
        guard session.activationState == .activated else {
            print("Watch session not active")
            return
        }
        
        if session.isReachable {
            session.sendMessage(message, replyHandler: replyHandler) { error in
                self.workoutStartFailed = true 
                print("Error sending message to watch: \(error.localizedDescription)")
            }
        } else if replyHandler == nil {
            do {
                try session.updateApplicationContext(message)
                print("Updated app context for delayed delivery")
            } catch {
                print("Error updating application context: \(error.localizedDescription)")
            }
        }
    }
    
    func startWorkout(rideId: UUID) {
        currentRideId = rideId
        
        let message: [String: Any] = [
            "rideId": rideId.uuidString,
            "timestamp": Date().timeIntervalSince1970,
            "type": "startWorkout"
        ]
        
        if session.isReachable {
            print("Watch is reachable, sending direct message")
            session.sendMessage(message, replyHandler: { reply in
                DispatchQueue.main.async {
                    if let success = reply["success"] as? Bool, success {
                        self.isWorkoutActive = true
                        print("Workout started successfully on watch via direct message")
                        self.startStatusCheckTimer()
                    } else {
                        print("Failed to start workout on watch via direct message")
                    }
                }
            }, errorHandler: { error in
                print("Error sending start workout message: \(error.localizedDescription)")
            })
        } else {
            print("Watch is not reachable, updating application context")
            do {
                try session.updateApplicationContext(message)
                print("Updated app context for delayed delivery")
            } catch {
                print("Error updating application context: \(error.localizedDescription)")
            }
        }
        
        print("Sent start workout message to watch for ride \(rideId)")
    }

    
    func stopWorkout() {
        sendMessage(.stopWorkout) { reply in
            DispatchQueue.main.async {
                if let success = reply["success"] as? Bool, success {
                    self.isWorkoutActive = false
                    self.stopStatusCheckTimer()
                    print("Workout stopped successfully on watch")
                } else {
                    print("Failed to stop workout on watch")
                }
            }
        }
        
        print("Sent stop workout message to watch")
    }
    
    func startWorkoutIfAvailable(rideId: UUID, completion: @escaping (Bool) -> Void) -> Void {
        if isReachable && isWatchAppInstalled {
            let message: [String: Any] = [
                "rideId": rideId.uuidString,
                "timestamp": Date().timeIntervalSince1970,
                "type": "startWorkout"
            ]
            
            if session.isReachable {
                print("Watch is reachable, sending direct message")
                session.sendMessage(message, replyHandler: { reply in
                    DispatchQueue.main.async {
                        if let success = reply["success"] as? Bool, success {
                            self.isWorkoutActive = true
                            print("Workout started successfully on watch via direct message")
                            
                            self.startStatusCheckTimer()
                            completion(true)
                        } else {
                            print("Failed to start workout on watch via direct message")
                            completion(false)
                        }
                    }
                }, errorHandler: { error in
                    print("Error sending start workout message: \(error.localizedDescription)")
                    completion(false)
                })
            } else {
                print("Watch is not reachable")
                completion(false)
            }
            
            return
        }
        
        completion(false)
    }
    
    private func startStatusCheckTimer() {
        statusCheckTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.checkWorkoutStatus()
        }
    }
    
    private func stopStatusCheckTimer() {
        statusCheckTimer?.invalidate()
        statusCheckTimer = nil
    }
    
    private func checkWorkoutStatus() {
        guard session.isReachable else {
            print("Watch not reachable during status check")
            return
        }
        
        print("Checking workout status with watch")
        sendMessage(.checkStatus) { reply in
            if let isActive = reply["isActive"] as? Bool {
                DispatchQueue.main.async {
                    print("Watch reports workout active: \(isActive), local state: \(self.isWorkoutActive)")
                    if !isActive && self.isWorkoutActive {
                        print("Watch reports workout not active, resyncing...")
                        if let rideId = self.currentRideId {
                            self.startWorkout(rideId: rideId)
                        }
                    } else if isActive && !self.isWorkoutActive {
                        self.isWorkoutActive = true
                    }
                }
            }
        }
    }
}

extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            if let error = error {
                self.watchStatus = "Error: \(error.localizedDescription)"
            } else {
                switch activationState {
                case .activated:
                    self.watchStatus = "Connected"
                    self.isWatchAppInstalled = session.isWatchAppInstalled
                case .inactive:
                    self.watchStatus = "Inactive"
                case .notActivated:
                    self.watchStatus = "Not Activated"
                @unknown default:
                    self.watchStatus = "Unknown"
                }
            }
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
            self.watchStatus = session.isReachable ? "Connected" : "Not Reachable"
            
            if session.isReachable && self.isWorkoutActive {
                self.checkWorkoutStatus()
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        handleMessage(message)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        guard let typeString = message["type"] as? String,
              let type = WatchMessageType(rawValue: typeString) else {
            replyHandler(["success": false, "error": "Invalid message type"])
            return
        }
        
        switch type {
        case .checkStatus:
            replyHandler(["isActive": isWorkoutActive])
            
        default:
            handleMessage(message)
            replyHandler(["success": true])
        }
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        handleMessage(applicationContext)
    }
    
    private func handleMessage(_ message: [String: Any]) {
        guard let typeString = message["type"] as? String,
              let type = WatchMessageType(rawValue: typeString) else {
            return
        }
        
        DispatchQueue.main.async {
            switch type {
            case .workoutData:
                self.processWorkoutData(message)
                
            case .biometricUpdate:
                self.processBiometricUpdate(message)
                
            case .statusResponse:
                if let isActive = message["isActive"] as? Bool {
                    self.isWorkoutActive = isActive
                }
            case .finalRideData:
                self.processFinalRideData(message)
                
            default:
                break
            }
        }
    }
    
    private func processFinalRideData(_ message: [String: Any]) {
        guard let rideIdString = message["rideId"] as? String,
              let rideId = UUID(uuidString: rideIdString),
              let averageHeartRate = message["averageHeartRate"] as? Double,
              let caloriesBurned = message["caloriesBurned"] as? Double else {
            return
        }
        
        DispatchQueue.main.async {
            if let context = self.modelContext {
                do {
                    let fetchDescriptor = FetchDescriptor<Ride>(predicate: #Predicate { $0.id == rideId })
                    if let ride = try context.fetch(fetchDescriptor).first {
                        ride.averageHeartRate = Int(averageHeartRate)
                        ride.caloriesBurned = Int(caloriesBurned)
                        
                        try context.save()
                        print("Ride updated successfully with final biometric data.")
                    }
                } catch {
                    print("Error updating ride with final data: \(error)")
                }
            }
        }
    }

    
    private func processWorkoutData(_ message: [String: Any]) {
        guard let rideIdString = message["rideId"] as? String,
              let rideId = UUID(uuidString: rideIdString),
              let heartRate = message["heartRate"] as? Double,
              let calories = message["calories"] as? Double else {
            print("Invalid workout data received")
            return
        }
        
        print("Received workout data for ride \(rideId): HR=\(heartRate), Cal=\(calories)")
        
        DispatchQueue.main.async {
            guard let modelContext = self.modelContext else {
                print("ModelContext not available")
                return
            }
            
            do {
                let descriptor = FetchDescriptor<Ride>(predicate: #Predicate { $0.id == rideId })
                let rides = try modelContext.fetch(descriptor)
                
                if let ride = rides.first {
                    ride.averageHeartRate = Int(heartRate)
                    ride.caloriesBurned = Int(calories)
                    try modelContext.save()
                    print("Updated ride with workout data")
                } else {
                    print("Ride not found: \(rideId)")
                }
            } catch {
                print("Error updating ride with workout data: \(error)")
            }
        }
    }
    
    private func processBiometricUpdate(_ message: [String: Any]) {
        if let heartRate = message["heartRate"] as? Double {
            self.heartRate = heartRate
        }
        
        if let calories = message["calories"] as? Double {
            self.activeCalories = calories
        }
        
        if let time = message["elapsedTime"] as? TimeInterval {
            self.elapsedTime = time
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        DispatchQueue.main.async {
            self.watchStatus = "Inactive"
        }
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        DispatchQueue.main.async {
            self.watchStatus = "Deactivated"
        }
        session.activate()
    }
}
