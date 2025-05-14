//
//  PressureMapView.swift
//  Cyclify
//
//  Created by Carolyn Yang on 5/13/25.
//

import SwiftUI
import UIKit

struct PressureSensorReading {
    let timestamp: Double
    let values: [Int]
    
    static func parseFromString(_ string: String) -> [PressureSensorReading] {
        let lines = string.components(separatedBy: .newlines)
        
        return lines.compactMap { line in
            let components = line.components(separatedBy: ": ")
            guard components.count == 2,
                  let timestamp = Double(components[0]),
                  let valuesString = components[1].dropFirst().dropLast().components(separatedBy: ", ")
                    .map({ Int($0) }) as? [Int] else {
                return nil
            }
            
            return PressureSensorReading(timestamp: timestamp, values: valuesString)
        }.sorted(by: { $0.timestamp < $1.timestamp })
    }
}

// Define sensor positions on the bicycle
struct SensorPosition {
    let x: CGFloat
    let y: CGFloat
    let name: String
    let sensorId: Int
    let type: SensorType
    
    enum SensorType {
        case seat
        case handlebar
    }
}


struct HandlebarPressureView: UIViewRepresentable {
    var pressureValues: [Int]
    var maxValue: Int
    var showLabels: Bool
    
    let sensorPositions: [SensorPosition] = [
        // Left side horizontal bar
        SensorPosition(x: 130, y: 180, name: "Left Bar", sensorId: 1, type: .handlebar),
        SensorPosition(x: 180, y: 180, name: "Left Center", sensorId: 5, type: .handlebar),
        
        // Right side horizontal bar
        SensorPosition(x: 420, y: 180, name: "Right Bar", sensorId: 3, type: .handlebar),
        SensorPosition(x: 470, y: 180, name: "Right Center", sensorId: 14, type: .handlebar),
        
        // Left drop
        SensorPosition(x: 80, y: 100, name: "Left Upper Drop", sensorId: 2, type: .handlebar),
        SensorPosition(x: 80, y: 140, name: "Left Lower Drop", sensorId: 6, type: .handlebar),
        
        // Right drop
        SensorPosition(x: 520, y: 100, name: "Right Upper Drop", sensorId: 4, type: .handlebar),
        SensorPosition(x: 520, y: 140, name: "Right Lower Drop", sensorId: 7, type: .handlebar)
    ]
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        uiView.subviews.forEach { $0.removeFromSuperview() }
        
        // Handlebar outline
        let handlebarView = UIView(frame: uiView.bounds)
        handlebarView.backgroundColor = .clear
        uiView.addSubview(handlebarView)
        
        // Handlebar shape
        let handlebarImageView = UIImageView(image: createHandlebarImage(size: handlebarView.bounds.size))
        handlebarImageView.frame = handlebarView.bounds
        handlebarView.addSubview(handlebarImageView)
        
        let heatMapView = UIView(frame: handlebarView.bounds)
        heatMapView.backgroundColor = .clear
        handlebarView.addSubview(heatMapView)
        
        let renderer = UIGraphicsImageRenderer(bounds: handlebarView.bounds)
        let heatMapImage = renderer.image { ctx in
            for position in sensorPositions {
                let sensorIndex = position.sensorId - 1
                guard sensorIndex >= 0 && sensorIndex < pressureValues.count else { continue }
                
                let value = pressureValues[sensorIndex]
                if value == 0 { continue }
                
                let normalizedValue = CGFloat(value) / CGFloat(maxValue)
                let scaledX = position.x / 600 * handlebarView.bounds.width
                let scaledY = position.y / 300 * handlebarView.bounds.height
              
                drawHeatSpot(ctx: ctx.cgContext, at: CGPoint(x: scaledX, y: scaledY), value: normalizedValue)
            }
        }
        
        let heatOverlayImageView = UIImageView(image: heatMapImage)
        heatOverlayImageView.frame = handlebarView.bounds
        heatMapView.addSubview(heatOverlayImageView)
        
        if showLabels {
            for position in sensorPositions {
                let scaledX = position.x / 600 * handlebarView.bounds.width
                let scaledY = position.y / 300 * handlebarView.bounds.height
                
                let label = UILabel(frame: CGRect(x: scaledX - 10, y: scaledY - 10, width: 20, height: 20))
                label.text = "\(position.sensorId)"
                label.textColor = .white
                label.textAlignment = .center
                label.font = UIFont.systemFont(ofSize: 10, weight: .bold)
                label.backgroundColor = UIColor(red: 0.5, green: 0.4, blue: 0.7, alpha: 0.8)
                label.layer.cornerRadius = 10
                label.layer.masksToBounds = true
                heatMapView.addSubview(label)
            }
        }
    }
    
    private func createHandlebarImage(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            let path = UIBezierPath()
            
            path.move(to: CGPoint(x: size.width * 0.1, y: size.height * 0.6))
            path.addLine(to: CGPoint(x: size.width * 0.9, y: size.height * 0.6))
            
            // Left drop
            path.move(to: CGPoint(x: size.width * 0.1, y: size.height * 0.6))
            path.addCurve(
                to: CGPoint(x: size.width * 0.13, y: size.height * 0.3),
                controlPoint1: CGPoint(x: size.width * 0.05, y: size.height * 0.55),
                controlPoint2: CGPoint(x: size.width * 0.08, y: size.height * 0.4)
            )
            
            // Right drop
            path.move(to: CGPoint(x: size.width * 0.9, y: size.height * 0.6))
            path.addCurve(
                to: CGPoint(x: size.width * 0.87, y: size.height * 0.3),
                controlPoint1: CGPoint(x: size.width * 0.95, y: size.height * 0.55),
                controlPoint2: CGPoint(x: size.width * 0.92, y: size.height * 0.4)
            )
            
            // Center stem
            path.move(to: CGPoint(x: size.width * 0.5, y: size.height * 0.6))
            path.addLine(to: CGPoint(x: size.width * 0.5, y: size.height * 0.8))
            
            ctx.cgContext.setStrokeColor(UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0).cgColor)
            ctx.cgContext.setLineWidth(8.0)
            path.stroke()
            
            // Grip areas
            let leftGripPath = UIBezierPath(roundedRect: CGRect(x: size.width * 0.05, y: size.height * 0.25, width: size.width * 0.08, height: size.height * 0.15), cornerRadius: 5)
            ctx.cgContext.setFillColor(UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0).cgColor)
            leftGripPath.fill()
            
            let rightGripPath = UIBezierPath(roundedRect: CGRect(x: size.width * 0.87, y: size.height * 0.25, width: size.width * 0.08, height: size.height * 0.15), cornerRadius: 5)
            rightGripPath.fill()
        }
    }
    
    private func drawHeatSpot(ctx: CGContext, at position: CGPoint, value: CGFloat) {
        let radius = max(25, value * 60)
        let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: [
                UIColor(red: 1, green: 0, blue: 0, alpha: min(0.9, value)).cgColor,
                UIColor(red: 1, green: 0.5, blue: 0, alpha: min(0.7, value * 0.8)).cgColor,
                UIColor(red: 1, green: 1, blue: 0, alpha: min(0.5, value * 0.6)).cgColor,
                UIColor.clear.cgColor
            ] as CFArray,
            locations: [0.0, 0.4, 0.7, 1.0]
        )!
        
        ctx.drawRadialGradient(
            gradient,
            startCenter: position,
            startRadius: 0.0,
            endCenter: position,
            endRadius: radius,
            options: .drawsBeforeStartLocation
        )
    }
}

struct SeatPressureView: UIViewRepresentable {
    var pressureValues: [Int]
    var maxValue: Int
    var showLabels: Bool

    let sensorPositions: [SensorPosition] = [
        SensorPosition(x: 240, y: 720, name: "Bottom Right", sensorId: 9, type: .seat),
        SensorPosition(x: 160, y: 720, name: "Bottom Left", sensorId: 10, type: .seat),
        SensorPosition(x: 230, y: 450, name: "Center Right", sensorId: 11, type: .seat),
        SensorPosition(x: 170, y: 450, name: "Center Left", sensorId: 12, type: .seat),
        SensorPosition(x: 200, y: 180, name: "Top Center", sensorId: 13, type: .seat)
    ]


    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        uiView.subviews.forEach { $0.removeFromSuperview() }

        let seatView = UIView(frame: uiView.bounds)
        seatView.backgroundColor = .clear
        uiView.addSubview(seatView)

        let seatImageView = UIImageView(image: createSeatImage(size: seatView.bounds.size))
        seatImageView.frame = seatView.bounds
        seatView.addSubview(seatImageView)

        let heatMapView = UIView(frame: seatView.bounds)
        heatMapView.backgroundColor = .clear
        seatView.addSubview(heatMapView)

        let renderer = UIGraphicsImageRenderer(bounds: seatView.bounds)
        let heatMapImage = renderer.image { ctx in
            for position in sensorPositions {
                let sensorIndex = position.sensorId - 1
                guard sensorIndex >= 0 && sensorIndex < pressureValues.count else { continue }
                let value = pressureValues[sensorIndex]
                if value == 0 { continue }
                let normalizedValue = CGFloat(value) / CGFloat(maxValue)
                let scaledX = position.x / 400 * seatView.bounds.width
                let scaledY = position.y / 800 * seatView.bounds.height
                drawHeatSpot(ctx: ctx.cgContext, at: CGPoint(x: scaledX, y: scaledY), value: normalizedValue)
            }
        }

        let heatOverlayImageView = UIImageView(image: heatMapImage)
        heatOverlayImageView.frame = seatView.bounds
        heatMapView.addSubview(heatOverlayImageView)

        if showLabels {
            for position in sensorPositions {
                let scaledX = position.x / 400 * seatView.bounds.width
                let scaledY = position.y / 800 * seatView.bounds.height

                let label = UILabel(frame: CGRect(x: scaledX - 15, y: scaledY - 15, width: 30, height: 30))
                label.text = "\(position.sensorId)"
                label.textColor = .white
                label.textAlignment = .center
                label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
                label.backgroundColor = UIColor(red: 0.5, green: 0.4, blue: 0.7, alpha: 0.8)
                label.layer.cornerRadius = 15
                label.layer.masksToBounds = true
                heatMapView.addSubview(label)
            }
        }
    }
    private func createSeatImage(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            let width = size.width
            let height = size.height

            let path = UIBezierPath()

            path.move(to: CGPoint(x: 0.5 * width, y: 0.01 * height))

            path.addCurve(
                to: CGPoint(x: 0.58 * width, y: 0.18 * height),
                controlPoint1: CGPoint(x: 0.52 * width, y: 0.06 * height),
                controlPoint2: CGPoint(x: 0.56 * width, y: 0.12 * height)
            )

            path.addCurve(
                to: CGPoint(x: 0.66 * width, y: 0.50 * height),
                controlPoint1: CGPoint(x: 0.63 * width, y: 0.30 * height),
                controlPoint2: CGPoint(x: 0.66 * width, y: 0.40 * height)
            )

            path.addQuadCurve(
                to: CGPoint(x: 0.60 * width, y: 0.97 * height),
                controlPoint: CGPoint(x: 0.74 * width, y: 0.78 * height)
            )

            path.addQuadCurve(
                to: CGPoint(x: 0.40 * width, y: 0.97 * height),
                controlPoint: CGPoint(x: 0.50 * width, y: 1.02 * height)
            )

            path.addQuadCurve(
                to: CGPoint(x: 0.34 * width, y: 0.50 * height),
                controlPoint: CGPoint(x: 0.26 * width, y: 0.78 * height)
            )

            path.addCurve(
                to: CGPoint(x: 0.42 * width, y: 0.18 * height),
                controlPoint1: CGPoint(x: 0.34 * width, y: 0.40 * height),
                controlPoint2: CGPoint(x: 0.38 * width, y: 0.28 * height)
            )

            path.addCurve(
                to: CGPoint(x: 0.5 * width, y: 0.01 * height),
                controlPoint1: CGPoint(x: 0.45 * width, y: 0.12 * height),
                controlPoint2: CGPoint(x: 0.48 * width, y: 0.06 * height)
            )

            path.close()

            ctx.cgContext.setStrokeColor(UIColor.gray.cgColor)
            ctx.cgContext.setLineWidth(2.0)
            path.stroke()

            ctx.cgContext.setFillColor(UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0).cgColor)
            path.fill()
        }
    }

    private func drawHeatSpot(ctx: CGContext, at position: CGPoint, value: CGFloat) {
        let radius = max(25, value * 50)
        let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: [
                UIColor(red: 1, green: 0, blue: 0, alpha: min(0.9, value)).cgColor,
                UIColor(red: 1, green: 0.5, blue: 0, alpha: min(0.7, value * 0.8)).cgColor,
                UIColor(red: 1, green: 1, blue: 0, alpha: min(0.5, value * 0.6)).cgColor,
                UIColor.clear.cgColor
            ] as CFArray,
            locations: [0.0, 0.4, 0.7, 1.0]
        )!
        ctx.drawRadialGradient(
            gradient,
            startCenter: position,
            startRadius: 0,
            endCenter: position,
            endRadius: radius,
            options: .drawsBeforeStartLocation
        )
    }
}


struct AccuratePressureVisualizationView: View {
    @State private var pressureReadings: [PressureSensorReading] = []
    @State private var currentIndex: Int = 0
    @State private var isPlaying: Bool = false
    @State private var timer: Timer?
    @State private var showSensorLabels: Bool = true
    @State private var selectedView: String = "Both"
    
    let maxPressureValue: Int = 4095
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 16) {
                Text("Pressure Distribution")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top)
                
                // View selector
                Picker("View", selection: $selectedView) {
                    Text("Both").tag("Both")
                    Text("Handlebars").tag("Handlebars")
                    Text("Seat").tag("Seat")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Pressure map visualization
                if !pressureReadings.isEmpty {
                    ZStack(alignment: .topTrailing) {
                        VStack(spacing: 0) {
                            if selectedView == "Both" || selectedView == "Handlebars" {
                                VStack {
                                    Text("Handlebar Pressure")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding(.top, 8)
                                    
                                    HandlebarPressureView(
                                        pressureValues: expandedPressureValues,
                                        maxValue: maxPressureValue,
                                        showLabels: showSensorLabels
                                    )
                                    .frame(height: selectedView == "Both" ? 180 : 300)
                                    .background(Color.black.opacity(0.9))
                                    .cornerRadius(12)
                                    .padding(.horizontal)
                                }
                            }
                            
                            if selectedView == "Both" || selectedView == "Seat" {
                                VStack {
                                    Text("Seat Pressure")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding(.top, selectedView == "Both" ? 16 : 8)
                                    
                                    SeatPressureView(
                                        pressureValues: expandedPressureValues,
                                        maxValue: maxPressureValue,
                                        showLabels: showSensorLabels
                                    )
                                    .frame(height: selectedView == "Both" ? 180 : 300)
                                    .background(Color.black.opacity(0.9))
                                    .cornerRadius(12)
                                    .padding(.horizontal)
                                }
                            }
                        }
                        
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
                                    .background(Color.blue)
                                    .clipShape(Circle())
                            }
                        }
                        .padding(12)
                    }
                } else {
                    Text("No data available")
                        .foregroundColor(.white)
                        .frame(height: 360)
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(12)
                }
                
                // Timeline slider
                if !pressureReadings.isEmpty {
                    VStack(spacing: 4) {
                        Slider(
                            value: Binding(
                                get: { Double(currentIndex) },
                                set: {
                                    currentIndex = Int($0)
                                    if isPlaying {
                                        isPlaying = false
                                        stopPlayback()
                                    }
                                }
                            ),
                            in: 0...Double(max(0, pressureReadings.count - 1)),
                            step: 1
                        )
                        .accentColor(.blue)
                        
                        HStack {
                            Text(formatTime(pressureReadings.first?.timestamp ?? 0))
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            Text(formatTime(pressureReadings[currentIndex].timestamp))
                                .font(.caption)
                                .bold()
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text(formatTime(pressureReadings.last?.timestamp ?? 0))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Pressure statistics
                if !pressureReadings.isEmpty && selectedView == "Both" {
                    PressureAnalysisView(pressureValues: expandedPressureValues)
                        .padding()
                        .background(Color.black.opacity(0.85))
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .onDisappear {
            stopPlayback()
        }
    }

    private var expandedPressureValues: [Int] {
        guard !pressureReadings.isEmpty else { return [] }
        
        let originalValues = pressureReadings[currentIndex].values
        
        if originalValues.count >= 14 {
            return originalValues
        }
        
        var expanded = Array(repeating: 0, count: 14)
        
        if originalValues.count > 4 {
            // Left handlebar sensors
            expanded[0] = originalValues[4] // Sensor 1
            expanded[1] = Int(Double(originalValues[4]) * 0.8) // Sensor 2
            expanded[4] = Int(Double(originalValues[4]) * 0.7) // Sensor 5
            expanded[5] = Int(Double(originalValues[4]) * 0.9) // Sensor 6
            
            // Right handlebar sensors
            expanded[2] = originalValues[5] // Sensor 3
            expanded[3] = Int(Double(originalValues[5]) * 0.8) // Sensor 4
            expanded[6] = Int(Double(originalValues[5]) * 0.9) // Sensor 7
            expanded[13] = Int(Double(originalValues[5]) * 0.7) // Sensor 14
        }
        
       
        if originalValues.count > 3 {
            expanded[8] = originalValues[0] // Sensor 9
            expanded[9] = Int(Double(originalValues[0]) * 0.9) // Sensor 10
            
            expanded[11] = originalValues[1] // Sensor 12
            expanded[12] = Int(Double(originalValues[1]) * 0.9) // Sensor 13
            
            // Center seat sensor
            expanded[10] = originalValues[2] // Sensor 11
        }
        
        return expanded
    }
    
    
    private func startPlayback() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            if currentIndex < pressureReadings.count - 1 {
                currentIndex += 1
            } else {
                currentIndex = 0
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
}

struct PressureAnalysisView: View {
    var pressureValues: [Int]
    
    // Define sensor groups
    private let seatSensors = [8, 9, 10, 11, 12]
    private let handlebarSensors = [0, 1, 2, 3, 4, 5, 6, 13]
    
    private let leftSeatSensors = [8, 9]
    private let rightSeatSensors = [11, 12]
    private let centerSeatSensors = [10]
    
    private let leftHandlebarSensors = [0, 1, 4, 5]
    private let rightHandlebarSensors = [2, 3, 6, 13]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Pressure Analysis")
                .font(.headline)
                .foregroundColor(.white)
            
            // Left/Right balance
            VStack(alignment: .leading, spacing: 8) {
                Text("Left/Right Balance")
                    .font(.subheadline)
                    .foregroundColor(.white)
                
                HStack {
                    Text("Left: \(Int(leftPercentage))%")
                        .font(.caption)
                        .foregroundColor(.orange)
                    
                    Spacer()
                    
                    Text("Right: \(Int(rightPercentage))%")
                        .font(.caption)
                        .foregroundColor(.purple)
                }
                
                GeometryReader { geometry in
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(Color.orange)
                            .frame(width: geometry.size.width * CGFloat(leftPercentage) / 100)
                        
                        Rectangle()
                            .fill(Color.purple)
                            .frame(width: geometry.size.width * CGFloat(rightPercentage) / 100)
                    }
                    .frame(height: 8)
                    .cornerRadius(4)
                }
                .frame(height: 8)
            }
            
            // Seat/Handlebar distribution
            VStack(alignment: .leading, spacing: 8) {
                Text("Seat vs Handlebar Pressure")
                    .font(.subheadline)
                    .foregroundColor(.white)
                
                HStack {
                    Text("Seat: \(Int(seatPercentage))%")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Text("Handlebar: \(Int(handlebarPercentage))%")
                        .font(.caption)
                        .foregroundColor(.green)
                }
                
                GeometryReader { geometry in
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(Color.blue)
                            .frame(width: geometry.size.width * CGFloat(seatPercentage) / 100)
                        
                        Rectangle()
                            .fill(Color.green)
                            .frame(width: geometry.size.width * CGFloat(handlebarPercentage) / 100)
                    }
                    .frame(height: 8)
                    .cornerRadius(4)
                }
                .frame(height: 8)
            }
            
            // Recommendations
            if !recommendations.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recommendations")
                        .font(.subheadline)
                        .foregroundColor(.white)
                    
                    ForEach(recommendations, id: \.self) {
                        recommendation in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "arrow.right.circle.fill")
                                .foregroundColor(.blue)
                                .font(.caption)
                            
                            Text(recommendation)
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.top, 4)
            }
        }
    }
    

    private var totalSeatPressure: Int {
        seatSensors.reduce(0) { sum, index in
            index < pressureValues.count ? sum + pressureValues[index] : sum
        }
    }
    
    private var totalHandlebarPressure: Int {
        handlebarSensors.reduce(0) { sum, index in
            index < pressureValues.count ? sum + pressureValues[index] : sum
        }
    }
    
    private var totalPressure: Int {
        totalSeatPressure + totalHandlebarPressure
    }
    

    private var leftSeatPressure: Int {
        leftSeatSensors.reduce(0) { sum, index in
            index < pressureValues.count ? sum + pressureValues[index] : sum
        }
    }
    
    private var rightSeatPressure: Int {
        rightSeatSensors.reduce(0) { sum, index in
            index < pressureValues.count ? sum + pressureValues[index] : sum
        }
    }
    
    private var centerSeatPressure: Int {
        centerSeatSensors.reduce(0) { sum, index in
            index < pressureValues.count ? sum + pressureValues[index] : sum
        }
    }
    
    private var leftHandlebarPressure: Int {
        leftHandlebarSensors.reduce(0) { sum, index in
            index < pressureValues.count ? sum + pressureValues[index] : sum
        }
    }
    
    private var rightHandlebarPressure: Int {
        rightHandlebarSensors.reduce(0) { sum, index in
            index < pressureValues.count ? sum + pressureValues[index] : sum
        }
    }
    
    private var leftPressure: Int {
        leftSeatPressure + leftHandlebarPressure
    }
    
    private var rightPressure: Int {
        rightSeatPressure + rightHandlebarPressure
    }
    
    private var seatPercentage: Double {
        totalPressure > 0 ? Double(totalSeatPressure) / Double(totalPressure) * 100 : 50
    }
    
    private var handlebarPercentage: Double {
        totalPressure > 0 ? Double(totalHandlebarPressure) / Double(totalPressure) * 100 : 50
    }
    
    private var leftPercentage: Double {
        totalPressure > 0 ? Double(leftPressure) / Double(totalPressure) * 100 : 50
    }
    
    private var rightPercentage: Double {
        totalPressure > 0 ? Double(rightPressure) / Double(totalPressure) * 100 : 50
    }
    
    private var imbalance: Double {
        abs(leftPercentage - rightPercentage)
    }
    
    private var recommendations: [String] {
        var tips: [String] = []
        
        if leftPercentage > rightPercentage + 10 {
            tips.append("Shift your weight more to the right side")
        }

        if rightPercentage > leftPercentage + 10 {
            tips.append("Shift your weight more to the left side")
        }

        if totalSeatPressure > 0 {
            if Double(leftSeatPressure) > Double(rightSeatPressure) * 1.5 {
                tips.append("You're leaning too far left on the seat")
            }

            if Double(rightSeatPressure) > Double(leftSeatPressure) * 1.5 {
                tips.append("You're leaning too far right on the seat")
            }

            if Double(centerSeatPressure) > Double(leftSeatPressure + rightSeatPressure) * 0.8 {
                tips.append("Too much pressure on the center of the seat")
            }
        }

        if totalHandlebarPressure > 0 {
            if Double(leftHandlebarPressure) > Double(rightHandlebarPressure) * 1.5 {
                tips.append("Distribute weight more evenly on handlebars (too much on left)")
            }

            if Double(rightHandlebarPressure) > Double(leftHandlebarPressure) * 1.5 {
                tips.append("Distribute weight more evenly on handlebars (too much on right)")
            }
        }
        
        if seatPercentage > 80 {
            tips.append("Too much weight on the seat, distribute some to the handlebars")
        }
        
        if handlebarPercentage > 60 {
            tips.append("Too much weight on the handlebars, shift back toward the seat")
        }
        
        if tips.isEmpty && imbalance <= 10 {
            tips.append("Good posture! Keep maintaining this balance.")
        }
        
        return tips
    }

    func sensorGroupView(title: String, value: Int, color: Color, maxValue: Int) -> some View {
        let percentage = maxValue > 0 ? Double(value) / Double(maxValue) * 100 : 0
        
        return VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.white)
            
            Text("\(Int(percentage))%")
                .font(.caption)
                .bold()
                .foregroundColor(color)
            
            GeometryReader { geometry in
                Rectangle()
                    .fill(color)
                    .frame(width: geometry.size.width * CGFloat(percentage) / 100)
                    .frame(height: 6)
                    .cornerRadius(3)
            }
            .frame(height: 6)
        }
    }
}


struct AccuratePressureVisualizationView_Previews: PreviewProvider {
    static var previews: some View {
        AccuratePressureVisualizationView()
    }
}
