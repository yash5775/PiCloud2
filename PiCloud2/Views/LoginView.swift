//
//  LoginView.swift
//  PiCloud2
//
//  Created for PiCloud project
//

import SwiftUI
import LocalAuthentication

struct LoginView: View {
    @AppStorage("username") private var username = ""
    @AppStorage("serverURL") private var serverURL = ""
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @AppStorage("useBiometrics") private var useBiometrics = false
    
    @State private var password = ""
    @State private var showAlert = false
    @State private var alertTitle = "Login Error"
    @State private var alertMessage = ""
    @State private var isLoggingIn = false
    @State private var navigateToDashboard = false
    
    // Keychain helper for secure credential storage
    private let keychainHelper = KeychainHelper()
    
    // Available biometric type
    private var biometricType: BiometricAuthHelper.BiometricType {
        BiometricAuthHelper.getBiometricType()
    }
    
    var body: some View {
        NavigationStack {
            ResponsiveContainer {
                VStack(spacing: HIGConstants.Spacing.large) {
                    // Header with logo
                    VStack(spacing: HIGConstants.Spacing.medium) {
                        Image(systemName: "cloud")
                            .font(.system(size: 60))
                            .foregroundColor(AppColors.primary)
                            .frame(minWidth: HIGConstants.minimumTouchTargetSize, minHeight: HIGConstants.minimumTouchTargetSize)
                            .padding()
                        
                        Text("PiCloud Login")
                            .titleStyle()
                        
                        Text("Connect to your WebDAV server")
                            .captionStyle()
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.bottom)
                    
                    // Login form
                    VStack(spacing: HIGConstants.Spacing.medium) {
                        AppTextField(placeholder: "Username", text: $username)
                        
                        AppTextField(placeholder: "Server URL (e.g., https://yourcloud.local)", text: $serverURL)
                        
                        // Password field
                        SecureField("Password", text: $password)
                            .padding()
                            .frame(minHeight: HIGConstants.minimumTouchTargetSize)
                            .background(AppColors.secondaryBackground)
                            .cornerRadius(HIGConstants.CornerRadius.medium)
                        
                        // Biometric login toggle
                        if biometricType != .none {
                            Toggle("Use \(biometricType.name)", isOn: $useBiometrics)
                                .padding(.vertical, HIGConstants.Spacing.small)
                        }
                        
                        // Login button
                        Button(action: validateAndLogin) {
                            if isLoggingIn {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            } else {
                                Text("Sign In")
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .disabled(isLoggingIn)
                        
                        // Biometric login button
                        if biometricType != .none && useBiometrics {
                            Button(action: authenticateWithBiometrics) {
                                HStack {
                                    Image(systemName: biometricType == .faceID ? "faceid" : "touchid")
                                    Text("Login with \(biometricType.name)")
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(SecondaryButtonStyle())
                            .disabled(isLoggingIn)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationDestination(isPresented: $navigateToDashboard) {
                DashboardView()
            }
            .alert(alertTitle, isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .onAppear {
                // Check if we can auto-login with biometrics
                if isLoggedIn && useBiometrics && !username.isEmpty {
                    authenticateWithBiometrics()
                }
            }
        }
    }
    
    private func validateAndLogin() {
        // Validate inputs
        if username.isEmpty {
            alertTitle = "Login Error"
            alertMessage = "Please enter a username"
            showAlert = true
            return
        }
        
        if serverURL.isEmpty {
            alertTitle = "Login Error"
            alertMessage = "Please enter a server URL"
            showAlert = true
            return
        }
        
        if password.isEmpty {
            alertTitle = "Login Error"
            alertMessage = "Please enter a password"
            showAlert = true
            return
        }
        
        // Start login process
        isLoggingIn = true
        
        // Simulate login for now
        // In a real implementation, this would call the WebDAVClient service
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            do {
                // Save credentials securely
                try keychainHelper.save(password, for: username)
                
                // Update login state
                isLoggedIn = true
                isLoggingIn = false
                navigateToDashboard = true
            } catch {
                // Handle keychain error
                isLoggingIn = false
                alertTitle = "Keychain Error"
                alertMessage = "Failed to save credentials: \(error.localizedDescription)"
                showAlert = true
            }
        }
    }
    
    private func authenticateWithBiometrics() {
        // Check if we have stored credentials
        do {
            // Try to retrieve password from keychain
            let _ = try keychainHelper.retrieve(for: username)
            
            // Authenticate with biometrics
            BiometricAuthHelper.authenticate { success, error in
                if success {
                    // Authentication successful, navigate to dashboard
                    isLoggedIn = true
                    navigateToDashboard = true
                } else if let error = error {
                    // Show error message
                    alertTitle = "Authentication Error"
                    alertMessage = error.message
                    showAlert = true
                }
            }
        } catch KeychainError.itemNotFound {
            // No stored credentials
            alertTitle = "Authentication Error"
            alertMessage = "No stored credentials found. Please log in with your password first."
            showAlert = true
        } catch {
            // Other keychain error
            alertTitle = "Keychain Error"
            alertMessage = "Failed to retrieve credentials: \(error.localizedDescription)"
            showAlert = true
        }
    }
}

#Preview {
    LoginView()
}