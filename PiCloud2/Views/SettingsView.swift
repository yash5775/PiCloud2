//
//  SettingsView.swift
//  PiCloud2
//
//  Created for PiCloud project
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("username") private var username = ""
    @AppStorage("serverURL") private var serverURL = ""
    @AppStorage("smartPlugShortcutName") private var shortcutName = "ToggleSmartPlug"
    @AppStorage("raspberryPiIP") private var raspberryPiIP = ""
    @AppStorage("apiToken") private var apiToken = ""
    
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack {
            ResponsiveContainer {
                Form {
                    // Server Settings Section
                    Section(header: Text("Server Settings")) {
                        HStack {
                            Text("Username")
                            Spacer()
                            Text(username)
                                .foregroundColor(AppColors.secondaryLabel)
                        }
                        
                        HStack {
                            Text("Server URL")
                            Spacer()
                            Text(serverURL)
                                .foregroundColor(AppColors.secondaryLabel)
                        }
                        
                        TextField("Raspberry Pi IP", text: $raspberryPiIP)
                        SecureField("API Token", text: $apiToken)
                    }
                    
                    // Smart Home Section
                    Section(header: Text("Smart Home")) {
                        TextField("Smart Plug Shortcut Name", text: $shortcutName)
                        
                        Button(action: toggleSmartPlug) {
                            HStack {
                                Image(systemName: "power")
                                Text("Toggle Smart Plug")
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .padding(.vertical, HIGConstants.Spacing.small)
                    }
                    
                    // Server Control Section
                    Section(header: Text("Server Control")) {
                        Button(action: { sendServerCommand(command: "restart") }) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("Restart Server")
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        .padding(.vertical, HIGConstants.Spacing.small)
                        
                        Button(action: { sendServerCommand(command: "shutdown") }) {
                            HStack {
                                Image(systemName: "power")
                                Text("Shutdown Server")
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        .padding(.vertical, HIGConstants.Spacing.small)
                    }
                    
                    // Account Section
                    Section {
                        Button(action: logout) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Logout")
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(.red)
                        }
                    }
                }
                .navigationTitle("Settings")
                .alert(alertTitle, isPresented: $showAlert) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(alertMessage)
                }
            }
        }
    }
    
    // Toggle smart plug using Siri Shortcuts
    private func toggleSmartPlug() {
        guard let shortcutURL = URL(string: "shortcuts://run-shortcut?name=\(shortcutName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") else {
            alertTitle = "Error"
            alertMessage = "Invalid shortcut name"
            showAlert = true
            return
        }
        
        UIApplication.shared.open(shortcutURL) { success in
            if !success {
                alertTitle = "Error"
                alertMessage = "Could not open Shortcuts app"
                showAlert = true
            }
        }
    }
    
    // Send command to server (restart/shutdown)
    private func sendServerCommand(command: String) {
        guard !raspberryPiIP.isEmpty else {
            alertTitle = "Error"
            alertMessage = "Please enter Raspberry Pi IP address"
            showAlert = true
            return
        }
        
        guard !apiToken.isEmpty else {
            alertTitle = "Error"
            alertMessage = "Please enter API token"
            showAlert = true
            return
        }
        
        // In a real implementation, this would send a request to the server
        // For now, just show a success message
        alertTitle = "Success"
        alertMessage = "\(command.capitalized) command sent to server"
        showAlert = true
    }
    
    // Logout function
    private func logout() {
        // Clear stored credentials (in a real app, also clear keychain)
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
    }
}

#Preview {
    SettingsView()
}