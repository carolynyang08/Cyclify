//
//  HeightInputView.swift
//  Cyclify
//
//  Created by Carolyn Yang on 3/23/25.
//

import SwiftUI

struct LevelInputView: View {
    var userModel: UserModel
    @ObservedObject var bluetoothManager: BluetoothManager
    @ObservedObject var calibrationModel: CalibrationModel
    
    @State private var trainingLevel: Int
    @Environment(\.presentationMode) var presentationMode
    

    let lightBlue = Color(red: 0.0, green: 0.67, blue: 1.0)
    let darkPurple = Color(red: 0.5, green: 0.0, blue: 1.0)
    

    init(userModel: UserModel, bluetoothManager: BluetoothManager, calibrationModel: CalibrationModel) {
        self.userModel = userModel
        self.bluetoothManager = bluetoothManager
        self.calibrationModel = calibrationModel
        

        _trainingLevel = State(initialValue: userModel.trainingLevel == 0 ? 1:userModel.trainingLevel )
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
                    .position(x: UIScreen.main.bounds.width - 30, y: UIScreen.main.bounds.height - 150)
                
                VStack {
                    Spacer().frame(height: 160)
                    Text("Select Your Training Level")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top)
                    
                    HStack {
                        // Feet picker
                        Picker("Level", selection: $trainingLevel) {
                            ForEach(1...5, id: \.self) { value in
                                Text("Level \(value)").tag(value)
                                    .foregroundColor(.white)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: geometry.size.width / 2 - 20, height: 150)
                        .padding(.horizontal)
                        
                        Text("Level \(trainingLevel)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    
                    NavigationLink(destination: DevicePairingView(userModel: userModel, bluetoothManager: bluetoothManager, calibrationModel: calibrationModel)) {
                        Text("Continue")
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
                    .padding(.bottom)
                    .simultaneousGesture(TapGesture().onEnded {
                            userModel.trainingLevel = trainingLevel
                            print("Saved training level: \(userModel.trainingLevel)")
                        })
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
        }
    }


#Preview {
    let user = UserModel(
        email: "preview@example.com",
        firstName: "Preview",
        lastName: "User",
        weight: 160,
        weightUnit: "LB",
        heightFeet: 5,
        heightInches: 10
    )

    return NavigationStack {
        LevelInputView(
            userModel: user,
            bluetoothManager: BluetoothManager(),
            calibrationModel: CalibrationModel()
        )
    }
}
