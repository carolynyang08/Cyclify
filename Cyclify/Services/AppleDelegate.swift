//
//  AppleDelegate.swift
//  Cyclify
//
//  Created by Carolyn Yang on 4/29/25.
//
import UIKit
import HealthKit


class AppDelegate: NSObject, UIApplicationDelegate {
    var mirroredSession: HKWorkoutSession?

    func application(_ application: UIApplication, handleWorkoutSession workoutSession: HKWorkoutSession) {
        mirroredSession = workoutSession
        mirroredSession?.delegate = self
    }
}

extension AppDelegate: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        print("Mirrored session changed: \(toState.rawValue)")
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("Mirrored session error: \(error.localizedDescription)")
    }
}
