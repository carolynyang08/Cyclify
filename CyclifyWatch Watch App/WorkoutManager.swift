//
//  WorkoutManager.swift
//  CyclifyWatch Extension
//
//  Created by Carolyn Yang on 4/19/25.
//

import Foundation
import WatchConnectivity
import HealthKit

enum WatchMessageType: String {
    case startWorkout
    case stopWorkout
    case workoutData
    case checkStatus
    case statusResponse
    case biometricUpdate
}

class WorkoutManager: NSObject, ObservableObject {
    static let shared = WorkoutManager()
    
    private let healthStore = HKHealthStore()
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?
    private var wcSession: WCSession?
    private var timer: Timer?
    private var currentRideId: UUID?
    
    @Published var isWorkoutActive = false
    @Published var heartRate: Double = 0
    @Published var activeCalories: Double = 0
    @Published var elapsedTime: TimeInterval = 0
    
    func requestAuthorizationIfNeeded() {
        let typesToShare: Set<HKSampleType> = [HKQuantityType.workoutType()]
        let typesToRead: Set<HKObjectType> = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        ]

        healthStore.getRequestStatusForAuthorization(toShare: typesToShare, read: typesToRead) { status, error in
            if status == .shouldRequest {
                self.healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
                    if !success {
                        print("Failed to re-request HealthKit permission: \(String(describing: error))")
                    }
                }
            }
        }
    }

    override init() {
        super.init()
        
        // Set up Watch Connectivity
        if WCSession.isSupported() {
            wcSession = WCSession.default
            wcSession?.delegate = self
            wcSession?.activate()
        }
        
        requestAuthorizationIfNeeded()
    }

    
    func startWorkout(rideId: UUID) {
        guard session == nil else { return }
        
        currentRideId = rideId
        
        healthStore.getRequestStatusForAuthorization(toShare: [HKObjectType.workoutType()], read: [
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        ]) { status, error in
            if status == .shouldRequest {
                self.healthStore.requestAuthorization(toShare: [HKObjectType.workoutType()], read: [
                    HKObjectType.quantityType(forIdentifier: .heartRate)!,
                    HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
                ]) { success, error in
                    if !success {
                        print("HealthKit authorization failed: \(String(describing: error))")
                    } else {
                        DispatchQueue.main.async {
                            Task {
                                do {
                                    try await self.startWorkoutSession(rideId: rideId)
                                } catch {
                                    print("Failed to start workout: \(error)")
                                }
                            }
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    Task {
                        do {
                            try await self.startWorkoutSession(rideId: rideId)
                        } catch {
                            print("Failed to start workout: \(error)")
                        }
                    }
                }
            }
        }
    }

    private func startWorkoutSession(rideId: UUID) async {
        do {
            let configuration = HKWorkoutConfiguration()
            configuration.activityType = .cycling
            configuration.locationType = .indoor

            session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            builder = session?.associatedWorkoutBuilder()
            
            builder?.dataSource = HKLiveWorkoutDataSource(
                healthStore: healthStore,
                workoutConfiguration: configuration
            )

            session?.delegate = self
            builder?.delegate = self

            session?.startActivity(with: Date())
            try await session?.startMirroringToCompanionDevice()
            builder?.beginCollection(withStart: Date()) { success, error in
                if !success {
                    print("Failed to begin workout collection: \(String(describing: error))")
                    return
                }
                
                DispatchQueue.main.async {
                    self.isWorkoutActive = true
                    self.startSendingUpdates()
                    self.sendWorkoutStateUpdate()
                }
            }
            
        } catch {
            print("Failed to start workout session: \(error.localizedDescription)")
        }
    }

    
    func stopWorkout() {
        guard let session = session else { return }
        
        session.end()
        stopSendingUpdates()
 
    }
    
    private func startSendingUpdates() {
        // Send updates every second
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.sendBiometricUpdate()
        }
    }
    
    private func stopSendingUpdates() {
        timer?.invalidate()
        timer = nil
    }
    
    private func sendBiometricUpdate() {
        guard let wcSession = wcSession, wcSession.isReachable, isWorkoutActive, let rideId = currentRideId else { return }
        
        let biometricMessage: [String: Any] = [
            "type": WatchMessageType.biometricUpdate.rawValue,
            "heartRate": heartRate,
            "calories": activeCalories,
            "elapsedTime": elapsedTime
        ]
        
        wcSession.sendMessage(biometricMessage, replyHandler: nil, errorHandler: { error in
            print("Error sending biometric update: \(error.localizedDescription)")
        })
        
        if Int(elapsedTime) % 10 == 0 {
            let workoutMessage: [String: Any] = [
                "type": WatchMessageType.workoutData.rawValue,
                "rideId": rideId.uuidString,
                "heartRate": heartRate,
                "calories": activeCalories
            ]
            
            wcSession.sendMessage(workoutMessage, replyHandler: nil, errorHandler: { error in
                print("Error sending workout data: \(error.localizedDescription)")
            })
        }
    }
    
    private func sendWorkoutStateUpdate() {
        guard let wcSession = wcSession else { return }
        
        let message: [String: Any] = [
            "type": WatchMessageType.statusResponse.rawValue,
            "isActive": isWorkoutActive,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        if wcSession.isReachable {
            wcSession.sendMessage(message, replyHandler: nil, errorHandler: { error in
                print("Error sending workout state update: \(error.localizedDescription)")
                
                do {
                    try wcSession.updateApplicationContext(message)
                } catch {
                    print("Error updating app context: \(error)")
                }
            })
        } else {
            do {
                try wcSession.updateApplicationContext(message)
            } catch {
                print("Error updating app context: \(error)")
            }
        }
        
    }
    
    private func updateForStatistics(_ statistics: HKStatistics?) {
        guard let statistics = statistics else { return }
        
        DispatchQueue.main.async {
            switch statistics.quantityType {
            case HKQuantityType.quantityType(forIdentifier: .heartRate):
                let heartRateUnit = HKUnit.count().unitDivided(by: .minute())
                self.heartRate = statistics.mostRecentQuantity()?.doubleValue(for: heartRateUnit) ?? 0
                
            case HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned):
                let energyUnit = HKUnit.kilocalorie()
                self.activeCalories = statistics.sumQuantity()?.doubleValue(for: energyUnit) ?? 0
                
            default:
                return
            }
        }
    }
}

extension WorkoutManager: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        DispatchQueue.main.async {
            switch toState {
            case .running:
                self.isWorkoutActive = true
                self.sendWorkoutStateUpdate()
                
            case .ended:
                self.builder?.endCollection(withEnd: date) { success, error in
                    if !success {
                        print("Error ending collection: \(String(describing: error))")
                    }
                    
                    self.builder?.finishWorkout { workout, error in
                        if let error = error {
                            print("Error finishing workout: \(error.localizedDescription)")
                        }
                        
                        DispatchQueue.main.async {
                            self.isWorkoutActive = false
                            self.session = nil
                            self.builder = nil
                            self.sendWorkoutStateUpdate()
                            
                        if let rideId = self.currentRideId {
                                   self.sendFinalRideData(rideId: rideId)
                               }
                        }
                    }
                }
                
            default:
                break
            }
        }
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("Workout session failed: \(error.localizedDescription)")
        
        DispatchQueue.main.async {
            self.isWorkoutActive = false
            self.session = nil
            self.builder = nil
            self.sendWorkoutStateUpdate()
        }
    }
}

extension WorkoutManager: HKLiveWorkoutBuilderDelegate {
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else { continue }
            
            let statistics = workoutBuilder.statistics(for: quantityType)
            updateForStatistics(statistics)
        }
        
        // Update elapsed time
        if let startDate = workoutBuilder.startDate {
            elapsedTime = Date().timeIntervalSince(startDate)
        }
    }
    
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
    
    }
}

extension WorkoutManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Handle activation completion
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        handleMessage(message, replyHandler: replyHandler)
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        handleMessage(applicationContext, replyHandler: nil)
    }
    
    private func sendFinalRideData(rideId: UUID) {
        guard let wcSession = wcSession, wcSession.isReachable else { return }
        
        let finalDataMessage: [String: Any] = [
            "type": "finalRideData",
            "rideId": rideId.uuidString,
            "averageHeartRate": heartRate,
            "caloriesBurned": activeCalories
        ]
        
        wcSession.sendMessage(finalDataMessage, replyHandler: nil, errorHandler: { error in
            print("Error sending final ride data: \(error.localizedDescription)")
        })
    }

    
    private func handleMessage(_ message: [String: Any], replyHandler: (([String: Any]) -> Void)?) {
        guard let typeString = message["type"] as? String else {
            replyHandler?(["success": false, "error": "Invalid message type"])
            return
        }
        
        let messageType: WatchMessageType
        if let type = WatchMessageType(rawValue: typeString) {
            messageType = type
        } else if typeString == "startWorkout" {
            messageType = .startWorkout
        } else if typeString == "stopWorkout" {
            messageType = .stopWorkout
        } else if typeString == "checkStatus" {
            messageType = .checkStatus
        } else {
            print("Watch received unknown message type: \(typeString)")
            replyHandler?(["success": false, "error": "Unknown message type"])
            return
        }
        
        DispatchQueue.main.async {
            switch messageType {
            case .startWorkout:
                if let rideIdString = message["rideId"] as? String,
                   let rideId = UUID(uuidString: rideIdString) {
                    if !self.isWorkoutActive {
                        self.startWorkout(rideId: rideId)
                        replyHandler?(["success": true])

                        DispatchQueue.main.async {
                            self.sendWorkoutStateUpdate()
                        }
                    } else {
                        replyHandler?(["success": true])
                    }
                } else {
                    replyHandler?(["success": false, "error": "Invalid ride ID"])
                }

                
            case .stopWorkout:
                if self.isWorkoutActive {
                    self.stopWorkout()
                    replyHandler?(["success": true])
                } else {
                    replyHandler?(["success": true])
                }
                
            case .checkStatus:
                replyHandler?(["isActive": self.isWorkoutActive])
                
            default:
                replyHandler?(["success": false, "error": "Unsupported message type"])
            }
        }
    }
}
