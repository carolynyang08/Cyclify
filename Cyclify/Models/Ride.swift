//
//  Ride.swift
//  Cyclify
//
//  Created by Carolyn Yang on 3/29/25.
//

import Foundation
import SwiftData

@Model
class Ride {
    @Attribute(.unique) var id: UUID
    var startTime: Date
    var endTime: Date?
    var averageHeartRate: Int?
    var caloriesBurned: Int?
    @Attribute var rideScore: Int?
    
    
    @Relationship(deleteRule: .cascade)
    var sensorData: [SensorReading] = []

    
    @Relationship var user: UserModel?
    
    @Relationship(deleteRule: .cascade, inverse: \RideAlert.ride)
    var alerts: [RideAlert] = []
    
    init(id: UUID = UUID(), startTime: Date, endTime: Date? = nil, averageHeartRate: Int? = nil, caloriesBurned: Int? = nil, sensorData: [SensorReading] = [], user: UserModel? = nil) {
            self.id = id
            self.startTime = startTime
            self.endTime = endTime
            self.averageHeartRate = averageHeartRate
            self.caloriesBurned = caloriesBurned
            self.sensorData = sensorData
            self.user = user
        }

    var duration: TimeInterval {
        guard let end = endTime else { return 0 }
        return end.timeIntervalSince(startTime)
    }

    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return "\(minutes)m \(seconds)s"
    }

    var formattedStartTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: startTime)
    }
}

@Model
class SensorReading {
    var timestamp: Double
    var sensors: [Int]
    
    @Relationship var ride: Ride?

    init(timestamp: Double, sensors: [Int], ride: Ride? = nil) {
        self.timestamp = timestamp
        self.sensors = sensors
        self.ride = ride
    }
}


struct TempSensorReading: Codable {
    let timestamp: Double
    let sensors: [Int]

    enum CodingKeys: String, CodingKey {
        case timestamp = "t"
        case sensors
    }
}
