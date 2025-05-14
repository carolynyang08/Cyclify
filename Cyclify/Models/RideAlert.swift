//
//  AlertModel.swift
//  Cyclify
//
//  Created by Carolyn Yang on 3/30/25.
//
import SwiftData
import SwiftUI


@Model
class RideAlert: Identifiable {
    var id: UUID
    var timestamp: Double
    var type: Int
    var intensity: Int

    @Relationship var ride: Ride?

    init(timestamp: Double, type: Int, intensity: Int, ride: Ride? = nil) {
        self.id = UUID()
        self.timestamp = timestamp
        self.type = type
        self.intensity = intensity
        self.ride = ride
    }
}

struct TempAlertReading: Codable {
    let timestamp: Double
    let alert: [Int]
}
