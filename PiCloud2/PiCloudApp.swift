//
//  PiCloudApp.swift
//  PiCloud2
//
//  Created for PiCloud project
//

import SwiftUI
import HomeKit
import LocalAuthentication

@main
struct PiCloudApp: App {
    @AppStorage("useBiometrics") private var useBiometrics = false
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @StateObject private var homeKitManager = HomeKitManager()
    
    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                DashboardView()
                    .environmentObject(homeKitManager)
            } else {
                LoginView()
            }
        }
        .onAppear {
            if useBiometrics && isLoggedIn {
                authenticateWithBiometrics()
            }
            if isLoggedIn {
                homeKitManager.requestAccess()
            }
        }
    }
    
    private func authenticateWithBiometrics() {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            print("Biometric authentication not available: \(error?.localizedDescription ?? "Unknown error")")
            return
        }
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                             localizedReason: "Unlock PiCloud") { success, error in
            DispatchQueue.main.async {
                if !success {
                    // On failure, log out the user
                    isLoggedIn = false
                }
            }
        }
    }
}