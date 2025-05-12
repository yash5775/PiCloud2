//
//  PiCloud2App.swift
//  PiCloud2
//
//  Created by Chaniyara Yash on 12/05/25.
//

import SwiftUI
import HomeKit
import LocalAuthentication

@main
struct PiCloud2App: App {
    @AppStorage("useBiometrics") private var useBiometrics = false
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @StateObject private var homeKitManager = HomeKitManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(homeKitManager)
                .onAppear {
                    if useBiometrics && isLoggedIn {
                        authenticateWithBiometrics()
                    }
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
