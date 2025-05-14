//
//  CalibrationIntroView.swift
//  Cyclify
//
//  Created by Carolyn Yang on 3/23/25.
//

import SwiftUI

struct CalibrationIntroView: View {
    var userModel: UserModel
    @ObservedObject var bluetoothManager: BluetoothManager
    @ObservedObject var calibrationModel: CalibrationModel
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss

    
    let lightBlue = Color(red: 0.0, green: 0.67, blue: 1.0) 
    let darkPurple = Color(red: 0.5, green: 0.0, blue: 1.0)
    
    var body: some View {
        NavigationView {
            ZStack {
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
                    .position(x: UIScreen.main.bounds.width - 30, y: UIScreen.main.bounds.height - 150)
                
                VStack{
                    Spacer()
                    Text("Calibration helps us fine-tune measurements for you.")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Text("We’ll collect some basic info to improve accuracy and optimize your experience.")
                        .font(.title3)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.top, 5)
                    
                    Spacer()
                }

                NavigationLink(destination: LevelInputView(userModel: userModel, bluetoothManager: bluetoothManager, calibrationModel: calibrationModel)) {
                        Text("Let's Start!")
                            .font(.headline)
                            .frame(maxWidth: 100)
                            .padding()
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [lightBlue, darkPurple]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(25)
                    }
                    .padding(.horizontal, 50)
                    .position(x: UIScreen.main.bounds.width/2, y: 0.65*UIScreen.main.bounds.height)
                }
            .toolbar(.hidden, for: .tabBar)
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
        CalibrationIntroView(
            userModel: userModel,
            bluetoothManager: BluetoothManager(),
            calibrationModel: CalibrationModel()
        )
    }
}
