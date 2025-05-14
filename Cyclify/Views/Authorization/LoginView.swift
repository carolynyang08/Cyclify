//
//  LoginView.swift
//  Cyclify
//
//  Created by Carolyn Yang on 3/23/25.
//

import SwiftUI
import SwiftData

struct LoginView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [UserModel]
    @ObservedObject var bluetoothManager: BluetoothManager

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showError: Bool = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                Text("Log In to Cyclify")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding(.top)
                
                if showError {
                    Text("Invalid email or password. Please try again.")
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .padding(.horizontal)
                }
                
                WhitePlaceholderTextField(placeholder: "Email Address", text: $email)
                    .padding(.horizontal)
                
                WhitePlaceholderSecureField(placeholder: "Password", text: $password)
                    .padding(.horizontal)
                
                Spacer()
                
                Button(action: handleLogin) {
                    Text("Log In")
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
        }
    }

    private func handleLogin() {
            guard let user = users.first(where: { $0.email == email }) else {
                showError = true
                return
            }

            let keychain = KeychainHelper()
            if keychain.checkPassword(email: user.email, password: password) {
                user.isLoggedIn = true
                try? modelContext.save()
                showError = false
            } else {
                showError = true
            }
        }
    }
#Preview {
    NavigationView {
        LoginView(bluetoothManager: BluetoothManager())
            .modelContainer(for: UserModel.self) 
    }
}
