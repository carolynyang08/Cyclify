//
//  FinishCalibration.swift
//  Cyclify
//
//  Created by Carolyn Yang on 3/29/25.
//
import SwiftUI

struct FinishCalibration: View {
    var userModel: UserModel
    @ObservedObject var bluetoothManager: BluetoothManager
    @ObservedObject var calibrationModel: CalibrationModel
    @State private var showMainView = false
    @Environment(\.presentationMode) var presentationMode


    var body: some View {
            ZStack {
                Color.black.ignoresSafeArea()

                Group {
                    Image("cyclify-bike")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .position(x: 40, y: 60)

                    Image("whitefireworks")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 1500)
                        .position(x: 60, y: 180)

                    Image("cyclify-bike")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .position(x: 370, y: 200)
                    
                    Image("cyclify-bike")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .position(x: 360, y: -30)

                    Image("whitefireworks")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .position(x: 350, y: 80)

                    Image("cyclify-bike")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180, height: 180)
                        .position(x: 35, y: 275)

                    Image("whitefireworks")
                        .resizable()
                        .frame(width: 170, height: 170)
                        .position(x: 370, y: 550)
                    
                    Image("whitefireworks")
                        .resizable()
                        .frame(width: 170, height: 170)
                        .position(x: 0, y: 670)
                    
                    Image("cyclify-bike")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .position(x: 390, y: 400)
                    
                    Image("cyclify-bike")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 205, height: 205)
                        .position(x: 40, y: 500)
                    
                    Image("cyclify-bike")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 275, height: 270)
                        .position(x: 200, y: 780)
                }

                VStack(spacing: 30) {
                    Text("Calibration\nFinished")
                        .font(.system(size: 45, weight: .bold))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    
                    Button(action: {
                        showMainView = true
                        }) {
                            Text("Start Riding!")
                                .font(.headline)
                                .padding()
                                .frame(width: 170)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.blue, Color.purple]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundColor(.white)
                                .cornerRadius(30)
                        }
                    }
                
                .fullScreenCover(isPresented: $showMainView) {
                    MainTabView(bluetoothManager: bluetoothManager,
                        calibrationModel: calibrationModel
                    )
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
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
        FinishCalibration(
            userModel: userModel,
            bluetoothManager: BluetoothManager(),
            calibrationModel: CalibrationModel()
        )
    }
}

