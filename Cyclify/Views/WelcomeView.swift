//
//  WelcomeView.swift
//  Cyclify
//
//  Created by Carolyn Yang on 3/23/25.
//

import SwiftUI

struct WelcomeView: View {
    @Binding var isRegistered: Bool
    @ObservedObject var bluetoothManager: BluetoothManager
    @ObservedObject var calibrationModel: CalibrationModel
    
    init(isRegistered: Binding<Bool>, bluetoothManager: BluetoothManager, calibrationModel: CalibrationModel) {
        self._isRegistered = isRegistered
        self.bluetoothManager = bluetoothManager
        self.calibrationModel = calibrationModel
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .black
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.shadowColor = nil
        
        appearance.setBackIndicatorImage(
            UIImage(systemName: "chevron.left")?.withTintColor(.white, renderingMode: .alwaysOriginal),
            transitionMaskImage: UIImage(systemName: "chevron.left")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        )
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor = .white
    }
    
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack {
                    Spacer()
                        .frame(height: 50)
                    
                    Text("Wecome to Cyclify")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .padding(.top)
                    
                    Spacer()
                        .frame(height: 30)
                    
                    Image("cyclify-high-resolution-logo-transparent")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250, height: 250)
                        .shadow(color: .white.opacity(0.3), radius: 5, x: 0, y: 0)
                        .padding(.vertical, 20)
                    
                    Text("Smart cycling for all.")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 10)
                    
                    Text("A posture correcting feedback system to help you improve your form and efficiency.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.top, 5)
                    
                    Spacer()
                    
                    NavigationLink(destination: RegisterView(
                        isRegistered: $isRegistered,
                        bluetoothManager: bluetoothManager,
                        calibrationModel: calibrationModel
                    )) {
                        HStack {
                            Text("Register an Account")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 5)
                    
                    
                    NavigationLink(destination: LoginView(
                        bluetoothManager: bluetoothManager
                    )) {
                        Text("Login")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
                .navigationTitle("")
                .navigationBarHidden(true)
            }
        }
    }
}
    

#Preview {
    WelcomeView(
        isRegistered: .constant(false),
        bluetoothManager: BluetoothManager(),
        calibrationModel: CalibrationModel()
    )
}
