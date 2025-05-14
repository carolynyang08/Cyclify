//
//  RegisterView.swift
//  Cyclify
//
//  Created by Carolyn Yang on 3/23/25.
//

import SwiftUI

struct WhitePlaceholderTextField: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.leading, 15)
            }
            TextField("", text: $text)
                .foregroundColor(.white)
                .padding()
                .background(Color.white.opacity(0.15))
                .cornerRadius(8)
        }
    }
}

struct WhitePlaceholderSecureField: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.leading, 15)
            }
            SecureField("", text: $text)
                .foregroundColor(.white)
                .padding()
                .background(Color.white.opacity(0.15))
                .cornerRadius(8)
        }
    }
}


struct RegisterView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode
    @Binding var isRegistered: Bool
    @ObservedObject var bluetoothManager: BluetoothManager
    @ObservedObject var calibrationModel: CalibrationModel

    
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                Text("Welcome to Cyclify")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding(.top)
                
                WhitePlaceholderTextField(placeholder: "First Name", text: $firstName)
                    .padding(.horizontal)
                    .padding(.top)
                
                WhitePlaceholderTextField(placeholder: "Last Name", text: $lastName)
                    .padding(.horizontal)
                
                WhitePlaceholderTextField(placeholder: "Email Address", text: $email)
                    .padding(.horizontal)

                WhitePlaceholderSecureField(placeholder: "Password", text: $password)
                    .padding(.horizontal)
 

                Spacer()
                Button(action: {
                    registerUser()
                }) {
                    Text("Register")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom)
                            }
            
                .padding(.horizontal)
                .padding(.bottom)

                .navigationTitle("Register")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(false)
            }
        }
    private func registerUser() {
        let newUser = UserModel(
            email: email,
            firstName: firstName,
            lastName: lastName,
            weight: 0.0,
            weightUnit: "LB",
            heightFeet: 0,
            heightInches: 0
        )
        modelContext.insert(newUser)
        newUser.savePassword(password)
        newUser.isLoggedIn = true
        do {
            try modelContext.save()
        } catch{
            print("Error saving user: \(error)")
        }
        KeychainHelper().savePassword(email: newUser.email, password: password)

        isRegistered = true
    }

    }
    
    

#Preview {
    RegisterView(
        isRegistered: .constant(false),
        bluetoothManager: BluetoothManager(),
        calibrationModel: CalibrationModel()
    )
    .modelContainer(for: [UserModel.self])
}
