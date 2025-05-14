//
//  DevicePairingView.swift
//  Cyclify
//
//  Created by Carolyn Yang on 3/23/25.
//

import SwiftUI
import SwiftData

struct DevicePairingView: View {
    var userModel: UserModel
    @ObservedObject var bluetoothManager: BluetoothManager
    @ObservedObject var calibrationModel: CalibrationModel
    @Environment(\.presentationMode) var presentationMode

    let lightBlue = Color(red: 0.0, green: 0.67, blue: 1.0) // #00ABFF
    let darkPurple = Color(red: 0.5, green: 0.0, blue: 1.0) // #8000FF

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

                    Text("Pair Your Device")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("Ensure your device is powered on and in pairing mode.")
                        .font(.title3)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 60)
                        .padding(.top, 20)

                    Spacer()
                }

                NavigationLink(destination: ConnectView(userModel: userModel, service: bluetoothManager, calibrationModel: calibrationModel)) {
                    Text("Scan for Devices")
                        .font(.headline)
                        .frame(maxWidth: 140)
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
                .position(x: geometry.size.width / 2, y: geometry.size.height * 0.65)
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
        firstName: "Preview",
        lastName: "User",
        weight: 160,
        weightUnit: "LB",
        heightFeet: 5,
        heightInches: 10
    )

    return NavigationStack {
        DevicePairingView(
            userModel: userModel,
            bluetoothManager: BluetoothManager(),
            calibrationModel: CalibrationModel()
        )
    }
}
