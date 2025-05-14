//
//  Untitled.swift
//  Cyclify
//
//  Created by Carolyn Yang on 3/15/25.
//

import SwiftUI

struct CalibrationStart: View {
    var userModel: UserModel
    @ObservedObject var bluetoothManager: BluetoothManager
    @ObservedObject var calibrationModel: CalibrationModel
    
    @Environment(\.presentationMode) var presentationMode
    
    let lightBlue = Color(red: 0.0, green: 0.67, blue: 1.0)
    let darkPurple = Color(red: 0.5, green: 0.0, blue: 1.0)
    
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
                    Spacer().frame(height: 160)
                    
                    // Title
                    Text("Calibration")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.bottom, 20)
                    
                    // Instructional text
                    Text("Follow the guided poses to calibrate your riding position.\nWhen you hear the countdown, mimic the displayed posture.")
                        .font(.title3)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Spacer()
                    
                    // "Got It!" button with NavigationLink
                    NavigationLink(destination: Calibrate1(userModel: userModel, bluetoothManager: bluetoothManager, calibrationModel: calibrationModel)) {
                        Text("Got It!")
                            .font(.headline)
                            .frame(width: 150, height: 50)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [lightBlue, darkPurple]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .clipShape(Capsule())

                    }
                    .padding(.bottom, 225)
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
        }
        .toolbar(.hidden, for: .tabBar)
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
        CalibrationStart(
            userModel: userModel,
            bluetoothManager: BluetoothManager(),
            calibrationModel: CalibrationModel()
        )
    }
}
