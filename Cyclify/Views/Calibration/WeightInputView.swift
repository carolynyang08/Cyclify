//
//  WeightInputView.swift
//  Cyclify
//
//  Created by Carolyn Yang on 3/23/25.
//

import SwiftUI
import SwiftData

struct WeightInputView: View {
    var userModel: UserModel
    @ObservedObject var bluetoothManager: BluetoothManager
    @ObservedObject var calibrationModel: CalibrationModel
    
    @State private var weight:Double
    @State private var unit: String
    @Environment(\.presentationMode) var presentationMode
    
    init(userModel: UserModel, bluetoothManager: BluetoothManager, calibrationModel: CalibrationModel) {
            self.userModel = userModel
            self.bluetoothManager = bluetoothManager
            self.calibrationModel = calibrationModel
        
            _weight = State(initialValue: userModel.weight == 0.0 ? 145 : userModel.weight)
            _unit = State(initialValue: userModel.weightUnit)
        }
    
    let lightBlue = Color(red: 0.0, green: 0.67, blue: 1.0)
    let darkPurple = Color(red: 0.5, green: 0.0, blue: 1.0)

    var body: some View {
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
                Spacer().frame(height: 170)
                Text("What Is Your Weight?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top)

               
                HStack {
                    Button(action: {
                        if unit == "LB" {
                            weight = weight * 0.453592
                        }
                        unit = "KG"
                    }) {
                        Text("KG")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(unit == "KG" ? Color.blue : Color.gray.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    Button(action: {
                        if unit == "KG" {
                            weight = weight / 0.453592
                        }
                        unit = "LB"
                    }) {
                        Text("LB")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(unit == "LB" ? Color.blue : Color.gray.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)

                // Weight picker
                Picker("Weight", selection: $weight) {
                    ForEach(50...300, id: \.self) { value in
                        Text("\(Int(value))").tag(Double(value))
                            .foregroundColor(.white)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 150)

                Text("\(Int(weight)) \(unit)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Spacer()

                NavigationLink(destination: LevelInputView(userModel: userModel, bluetoothManager: bluetoothManager, calibrationModel: calibrationModel)) {
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
                    userModel.weight = weight
                    userModel.weightUnit = unit
                    print("Saved weight: \(userModel.weight) \(userModel.weightUnit)")
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

    return NavigationStack {
        WeightInputView(
            userModel: userModel,
            bluetoothManager: BluetoothManager(),
            calibrationModel: CalibrationModel()
        )
    }
}

