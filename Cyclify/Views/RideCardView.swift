//
//  RideCardView.swift
//  Cyclify
//
//  Created by Carolyn Yang on 3/29/25.
//

import SwiftUI
import SwiftData
import Charts

struct RideCardView: View {
    let ride: Ride
    let customCyan = Color(red: 145 / 255, green: 255 / 255, blue: 255 / 255)
    let customBlue = Color(red: 8 / 255, green: 196 / 255, blue: 252 / 255)
    
    
    var body: some View {
        NavigationLink(destination: RideDetailView(ride: ride)) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "bicycle")
                    Text("Cycle")
                        .fontWeight(.semibold)
                    Circle()
                        .frame(width: 6, height: 6)
                    Text(ride.formattedStartTime)
                        .font(.subheadline)
                        .bold()
                }

                HStack(spacing: 20){
                    VStack(alignment: .leading) {
                        Text("Time")
                            .font(.caption)
                        Text(ride.formattedDuration)
                            .bold()
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("Avg HR")
                            .font(.caption)
                        Text("\(ride.averageHeartRate ?? 0) bpm")
                            .bold()
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("Cal")
                            .font(.caption)
                        Text("\(ride.caloriesBurned ?? 0) cal")
                            .bold()
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                }
            }
            .foregroundColor(customBlue)
            .padding()
            .background(customCyan)
            .cornerRadius(18)
            .padding(.horizontal, 10)
        }
    }
}

struct RideDetailView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var sensorReadings: [SensorReading] = []
    @State private var rideAlerts: [RideAlert] = []
    @State private var showSensorLabels: Bool = true
    @State private var currentReadingIndex: Int = 0
    @State private var isPlaying: Bool = false
    @State private var timer: Timer?
    @State private var selectedPressureView: String = "Seat"
    @State private var rideScore: Int = 0
    
    let ride: Ride
    let customCyan = Color(red: 145 / 255, green: 255 / 255, blue: 252 / 255)
    let customBlue = Color(red: 8 / 255, green: 196 / 255, blue: 252 / 255)
    let customLavender = Color(red: 184 / 255.0, green: 180 / 255.0, blue: 244 / 255.0)
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Morning Ride")
                    .font(.largeTitle)
                    .bold()
                
                Text(ride.formattedStartTime)
                    .font(.subheadline)
                
                HStack {
                    VStack {
                        Text("Elapsed Time")
                            .font(.caption)
                            .fontWeight(.bold)
                        Text(ride.formattedDuration)
                            .bold()
                    }
                    Spacer()
                    VStack {
                        Text("Avg Heart Rate")
                            .font(.caption)
                            .fontWeight(.bold)
                        Text("\(ride.averageHeartRate ?? 0) bpm")
                            .bold()
                    }
                    Spacer()
                    VStack {
                        Text("Calories")
                            .fontWeight(.bold)
                            .font(.caption)
                        Text("\(ride.caloriesBurned ?? 0)")
                            .bold()
                    }
                }
                .padding()
                .background(customBlue)
                .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Ride Score")
                        .font(.title3)
                        .bold()

                    Text("Your ride scored \(rideScore)/100")
                        .font(.title2)
                        .bold()
                        .foregroundColor(scoreColor(rideScore))
                        .frame(maxWidth: .infinity, alignment: .center)

                    Text(encouragement(for: rideScore))
                        .font(.subheadline)
                        .italic()
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)


                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Pressure Distribution")
                        .font(.title3)
                        .bold()
                    
                    Picker("View", selection: $selectedPressureView) {
                        Text("Seat").tag("Seat")
                        Text("Handlebars").tag("Handlebars")
                        Text("Both").tag("Both")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.bottom, 4)
            
                    if !sensorReadings.isEmpty {
                        HStack {
                            Toggle("Labels", isOn: $showSensorLabels)
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.black.opacity(0.6))
                                .cornerRadius(8)
                            
                            Spacer()
                            
                            Button(action: {
                                isPlaying.toggle()
                                if isPlaying {
                                    startPlayback()
                                } else {
                                    stopPlayback()
                                }
                            }) {
                                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .background(customBlue)
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.bottom, 8)
                        
                        if !sensorReadings.isEmpty {
                            VStack(spacing: 16) {
                                if selectedPressureView == "Both" || selectedPressureView == "Handlebars" {
                                    VStack(alignment: .leading) {
                                        Text("Handlebar Pressure")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .padding(.leading, 12)
                                            .padding(.top, 8)
                                        
                                        HandlebarPressureView(
                                            pressureValues: currentSensorValues,
                                            maxValue: 4095,
                                            showLabels: showSensorLabels
                                        )
                                        .frame(height: selectedPressureView == "Both" ? 180 : 250)
                                        .background(Color.black.opacity(0.9))
                                        .cornerRadius(12)
                                    }
                                }
                                
                                if selectedPressureView == "Both" || selectedPressureView == "Seat" {
                                    VStack(alignment: .leading) {
                                        Text("Seat Pressure")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .padding(.leading, 12)
                                            .padding(.top, 8)
                                        
                                        SeatPressureView(
                                            pressureValues: currentSensorValues,
                                            maxValue: 4095,
                                            showLabels: showSensorLabels
                                        )
                                        .frame(height: selectedPressureView == "Both" ? 180 : 250)
                                        .background(Color.black.opacity(0.9))
                                        .cornerRadius(12)
                                    }
                                }
                            }
                            
                            // Timeline slider
                            VStack(spacing: 4) {
                                if sensorReadings.count > 1{
                                Slider(
                                    value: Binding(
                                        get: { Double(currentReadingIndex) },
                                        set: {
                                            currentReadingIndex = Int($0)
                                            if isPlaying {
                                                isPlaying = false
                                                stopPlayback()
                                            }
                                        }
                                    ),
                                    in: 0...Double(max(0, sensorReadings.count - 1)),
                                    step: 1
                                )
                                .accentColor(customBlue)
                            }
                                HStack {
                                    let sortedReadings = sensorReadings.sorted(by: { $0.timestamp < $1.timestamp })
                                    let minTimestamp = sortedReadings.first?.timestamp ?? 0
                                    
                                    Text("0:00")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    
                                    Spacer()
                                    
                                    Text(formatTime(sortedReadings[safe: currentReadingIndex]?.timestamp ?? 0 - minTimestamp))
                                        .font(.caption)
                                        .bold()
                                    
                                    Spacer()
                                    
                                    Text(formatTime((sortedReadings.last?.timestamp ?? 0) - minTimestamp))
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.horizontal)
                        } else {
                            Text("No pressure data available")
                                .foregroundColor(.gray)
                                .frame(height: 200)
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(12)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Form Violations")
                        .font(.title3)
                        .bold()

                    if rideAlerts.isEmpty {
                        Text("No form alerts available.")
                            .foregroundColor(.gray)
                    } else {
                        AlertBarChart(alerts: rideAlerts)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Form Deviation Frequency")
                        .font(.title3)
                        .bold()

                    if rideAlerts.isEmpty {
                        Text("No alert frequency data available.")
                            .foregroundColor(.gray)
                    } else {
                        RideAlertFreqChart(alerts: rideAlerts)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)


            }
            .padding()
        }
        .navigationTitle("Activities")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadSensorData()
            loadAlerts()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    let score = computeRideScore(alerts: rideAlerts, rideDuration: ride.duration)
                    rideScore = score

                    if ride.rideScore == nil || ride.rideScore != score {
                        ride.rideScore = score
                        try? modelContext.save()
                    }
                }
        }
        .onDisappear {
            stopPlayback()
        }
    }
    
    // Current sensor values for visualization
    private var currentSensorValues: [Int] {
        guard !sensorReadings.isEmpty else { return Array(repeating: 0, count: 14) }
        let sortedReadings = sensorReadings.sorted(by: { $0.timestamp < $1.timestamp })
        return sortedReadings[safe: currentReadingIndex]?.sensors ?? Array(repeating: 0, count: 14)
    }

    private func startPlayback() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            if currentReadingIndex < sensorReadings.count - 1 {
                currentReadingIndex += 1
            } else {
                currentReadingIndex = 0
                isPlaying = false
                stopPlayback()
            }
        }
    }

    private func stopPlayback() {
        timer?.invalidate()
        timer = nil
    }

    private func formatTime(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, secs)
    }
    
    private func loadSensorData() {
        let fetchRequest = FetchDescriptor<SensorReading>()

        do {
            let allReadings = try modelContext.fetch(fetchRequest)
            sensorReadings = allReadings.filter { $0.ride?.id == ride.id }

        } catch {
            print("Failed to load sensor readings: \(error)")
        }
    }
    

    private func computeRideScore(alerts: [RideAlert], rideDuration: TimeInterval) -> Int {
        let totalAlerts = alerts.count
        let avgIntensity = Double(alerts.map(\.intensity).reduce(0, +)) / max(1.0, Double(totalAlerts))
        let durationMinutes = max(1.0, rideDuration / 60.0)

        let alertsPerMin = Double(totalAlerts) / durationMinutes
        let alertPenalty = min(alertsPerMin * 0.5, 50.0)
        let intensityPenalty = min(avgIntensity * 0.2, 20.0)

        let rawScore = 100.0 - alertPenalty - intensityPenalty

        return max(0, min(100, Int(rawScore.rounded())))
    }


    private func encouragement(for score: Int) -> String {
        switch score {
        case 90...100: return "Elite form! You're crushing it."
        case 75..<90: return "Solid work! You're riding strong."
        case 50..<75: return "Keep refining, progress is happening!"
        default: return "Every ride is a step forward. Keep going!"
        }
    }
    

    private func scoreColor(_ score: Int) -> Color {
        switch score {
        case 90...100: return .green
        case 70..<90: return .yellow
        case 50..<70: return .orange
        default: return .red
        }
    }

    
    private func loadAlerts() {
        let fetchRequest = FetchDescriptor<RideAlert>()

        do {
            let allAlerts = try modelContext.fetch(fetchRequest)
            rideAlerts = allAlerts.filter { $0.ride?.id == ride.id }

            print("Loaded \(rideAlerts.count) alerts for ride \(ride.id)")
            for alert in rideAlerts {
                print("\(alert.timestamp): Type \(alert.type), Intensity \(alert.intensity)")
            }
        } catch {
            print("Failed to load ride alerts: \(error)")
        }
    }
}

extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

private struct RideAlertFreqChart: View {
    let alerts: [RideAlert]
    let customBlue = Color(red: 8 / 255, green: 196 / 255, blue: 252 / 255)

    var body: some View {
        let bucketSize = 10.0  // seconds
        let grouped = Dictionary(grouping: alerts) {
            Int($0.timestamp / bucketSize) * Int(bucketSize)
        }

        let sortedBuckets = grouped.keys.sorted()
        let points = sortedBuckets.map { bucket in
            (time: bucket, count: grouped[bucket]?.count ?? 0)
        }

        Chart {
            ForEach(points, id: \.time) { point in
                LineMark(
                    x: .value("Time (s)", point.time),
                    y: .value("Form Errors", point.count)
                )
                .foregroundStyle(customBlue)
                .symbol(by: .value("Type", "Form Alerts"))
            }
        }
        .frame(height: 250)
        .chartYAxisLabel("Alerts")
        .chartXAxisLabel("Time (seconds)")
    }
}

private struct AlertBarChart: View {
    let alerts: [RideAlert]
    let customCyan = Color(red: 145 / 255, green: 255 / 255, blue: 252 / 255)
    let customBlue = Color(red: 8 / 255, green: 196 / 255, blue: 252 / 255)
    let customLavender = Color(red: 184 / 255.0, green: 180 / 255.0, blue: 244 / 255.0)
    let customPurple = Color(red: 204 / 255, green: 136 / 255, blue: 153 / 255)

    var body: some View {
        let alertCounts = Dictionary(grouping: alerts, by: { $0.type })
            .mapValues { $0.count }

        Chart {
            ForEach(alertCounts.sorted(by: { $0.key < $1.key }), id: \.key) { (type, count) in
                BarMark(
                    x: .value("Violation Type", alertTypeToName(type)),
                    y: .value("Count", count)
                )
                .foregroundStyle(colorForType(type))
            }
        }
        .frame(height: 250)
        .chartYAxisLabel("Frequency")
        .chartXAxisLabel("Violation Type")
    }

    private func alertTypeToName(_ type: Int) -> String {
        // Map the integer type to the corresponding alert type name
        switch type {
        case 1: return "Leaning Left"
        case 2: return "Leaning Right"
        case 3: return "Leaning Forward"
        case 4: return "Leaning Backward"
        default: return "Unknown"
        }
    }
    

    private func colorForType(_ type: Int) -> Color {
        switch type {
        case 1: return customLavender
        case 2: return customPurple
        case 3: return customCyan
        case 4: return customBlue
        default: return Color.gray
        }
    }
}
