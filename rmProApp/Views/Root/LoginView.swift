//
//  LoginView.swift
//  rmProApp
//
//  Created by William Castellano on 8/27/25.
//


import SwiftUI

struct LoginView: View {
    @StateObject private var tokenManager = TokenManager.shared
    @State private var username = ""
    @State private var password = ""
    @State private var saveCredentials = true
    @State private var isLoading = false
    @State private var showError = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Logo or App Title
            Image(systemName: "building.2.crop.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
            
            Text("RentManager Pro")
                .font(.largeTitle)
                .bold()
            
            VStack(spacing: 15) {
                // Username Field
                TextField("Username", text: $username)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                // Password Field
                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
                
                // Save Credentials Toggle
                Toggle("Remember me", isOn: $saveCredentials)
                    .font(.subheadline)
                
                // Login Button
                Button(action: login) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Sign In")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(isFormValid ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(!isFormValid || isLoading)
            }
            .padding(.horizontal, 30)
            
            Spacer()
        }
        .padding()
        .alert("Authentication Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(tokenManager.authenticationError?.localizedDescription ?? "Unknown error")
        }
    }
    
    private var isFormValid: Bool {
        !username.isEmpty && !password.isEmpty
    }
    
    private func login() {
        isLoading = true
        
        Task {
            let success = await tokenManager.authenticate(
                username: username,
                password: password,
                saveCredentials: saveCredentials
            )
            
            isLoading = false
            
            if !success {
                showError = true
            }
        }
    }
}
