//
//  Calibrate2.swift
//  Cyclify
//
//  Created by Carolyn Yang on 3/28/25.
//

import SwiftUI
import SwiftData

struct Calibrate2: View {
    var userModel: UserModel
    @ObservedObject var bluetoothManager: BluetoothManager
    @ObservedObject var calibrationModel: CalibrationModel
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isCalibrating = false
    @State private var forceReadings: [[Int]] = []
    @State private var timer: Timer? = nil
    @State private var elapsedTime: Int = 0
    @State private var countdownValue: Int? = nil
    @State private var navigateToNext: Bool = false


    let lightBlue = Color(red: 0.0, green: 0.67, blue: 1.0)
    let darkPurple = Color(red: 0.5, green: 0.0, blue: 1.0)
    
    private var buttonLabel: String {
        if isCalibrating {
            return "Calibrating..."
        } else if elapsedTime >= 10 {
            return "Next"
        } else {
            return "Start"
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                Image("cyclify-bike")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [lightBlue, darkPurple]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .position(x: 40, y: 60)
                
             
                Image("cyclify-bike")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [lightBlue, darkPurple]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .position(x: geometry.size.width - 30, y: geometry.size.height - 150)
                
                VStack {
                    Spacer().frame(height: 60)
                    
                    Text("Posture Calibration: Lean Right")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .lineLimit(nil)
                        .padding(.bottom, 10)
                        .padding(.horizontal, 30)
                    
                    Text("Hold this position while we capture your posture data.")
                        .font(.title3)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                        .padding(.bottom, 20)
                        .lineLimit(nil)
         
                    Image("lean-right")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width - 80, height: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.bottom, 20)
                    
                    if !calibrationModel.getReadings(for: .leanRight).isEmpty {
                        Text(isCalibrating ? "\(30 - elapsedTime) seconds remaining" : "Calibration Complete")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding(.bottom, 10)

                        ScrollView {
                            VStack(alignment: .leading) {
                                ForEach(Array(calibrationModel.getReadings(for: .leanRight).enumerated()), id: \.offset) { index, readings in
                                    Text("Reading \(index + 1): \(readings.map { "\($0)" }.joined(separator: ", ")) N")
                                        .foregroundColor(.white)
                                        .font(.body)
                                }
                            }
                        }
                        .frame(height: 150)
                        .padding(.horizontal, 40)
                    }

                    
                    Spacer()
                    
                    if let countdown = countdownValue {
                        Text("Starting in \(countdown)")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.bottom, 10)
                            .transition(.opacity)
                    } else {
                        Button(action: {
                            startCalibration()
                        }) {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                    .foregroundColor(.white)
                                Text("Redo")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.bottom, 10)
                        .disabled(isCalibrating)
                    }

                    
                    NavigationLink(
                        destination: Calibrate3(userModel: userModel, bluetoothManager: bluetoothManager, calibrationModel: calibrationModel),
                        isActive: $navigateToNext
                    ) {
                        Button(action: {
                            if !isCalibrating && elapsedTime >= 30 {
                                navigateToNext = true
                            } else if !isCalibrating {
                                startCalibration()
                            }
                          
                        }) {
                            ZStack {
                                if isCalibrating {
                                    GradientProgressBar(progress: Double(elapsedTime)/30.0)
                                        .frame(width: 150, height: 12)
                                        .clipShape(Capsule())
                                } else if countdownValue == nil {
                                    Text(elapsedTime >= 30 ? "Next" : "Start")
                                        .font(.headline)
                                        .frame(width: 150, height:50)
                                        .background(LinearGradient(
                                            gradient: Gradient(colors: [lightBlue, darkPurple]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .foregroundColor(.white)
                                    .clipShape(Capsule())
                                }
                            }
                        }
                        .disabled(isCalibrating)
                    }
                    .padding(.bottom, 60)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                    Text("Back")
                        .foregroundColor(.white)
                }
            })
            .onChange(of: bluetoothManager.sensorData) { newValue in
                if isCalibrating, let data = newValue.data(using: .utf8) {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let sensors = json["sensors"] as? [Int] {
                            calibrationModel.addReadings(for: .leanRight, readings: sensors)
                        }
                    } catch {
                        print("Error parsing sensor data: \(error)")
                    }
                }
            }
        }
    }
    
    private func startCalibration() {
        guard !isCalibrating else { return }
        
        // Reset state
        resetCalibration()
        countdownValue = 3
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if let value = countdownValue, value > 1 {
                countdownValue = value - 1
            } else {
                timer.invalidate()
                countdownValue = nil
                beginCalibration()
            }
        }
    }
    
    private func beginCalibration() {
        bluetoothManager.sendCalibrationCommand("CALIBRATE:2")
        print("Sent calibration command 2")

        isCalibrating = true
        elapsedTime = 0

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            elapsedTime += 1
            if elapsedTime >= 30 {
                stopCalibration()
            }
        }
    }
    
    // Stop the calibration process
    private func stopCalibration() {
        isCalibrating = false
        timer?.invalidate()
        timer = nil
    }
    
    private func resetCalibration() {
        isCalibrating = false
        calibrationModel.resetReadings(for: .leanRight)
        elapsedTime = 0
        timer?.invalidate()
        timer = nil
    }
}


#Preview {
    let userModel = UserModel(
        email: "preview@example.com",
        firstName: "Test",
        lastName: "User",
        weight: 160,
        weightUnit: "LB",
        heightFeet: 5,
        heightInches: 10,
        trainingLevel: 3
    )

    NavigationStack {
        Calibrate2(
            userModel: userModel,
            bluetoothManager: BluetoothManager(),
            calibrationModel: CalibrationModel()
        )
    }
}
