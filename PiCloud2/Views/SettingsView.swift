//
//  SettingsView.swift
//  PiCloud2
//
//  Created for PiCloud project
//

import SwiftUI
import HomeKit

struct SettingsView: View {
    @AppStorage("username") private var username = ""
    @AppStorage("serverURL") private var serverURL = ""
    @AppStorage("smartPlugShortcutName") private var shortcutName = "ToggleSmartPlug"
    @AppStorage("raspberryPiIP") private var raspberryPiIP = ""
    @AppStorage("apiToken") private var apiToken = ""
    
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @StateObject private var homeKitManager = HomeKitManager()
    
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
                    
                    // HomeKit Section
                    Section(header: Text("HomeKit")) {
                        if homeKitManager.isAuthorized {
                            ForEach(homeKitManager.accessories, id: \.uniqueIdentifier) { accessory in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(accessory.name)
                                        if let room = accessory.room {
                                            Text(room.name)
                                                .font(.caption)
                                                .foregroundColor(AppColors.secondaryLabel)
                                        }
                                    }
                                    Spacer()
                                    Button(action: { homeKitManager.togglePlug(accessory) }) {
                                        Image(systemName: "power")
                                            .frame(minWidth: HIGConstants.minimumTouchTargetSize, minHeight: HIGConstants.minimumTouchTargetSize)
                                    }
                                }
                            }
                        } else {
                            Button("Request HomeKit Access") {
                                homeKitManager.requestAccess()
                            }
                        }
                    }
                    
                    // Server Control Section
                    Section(header: Text("Server Control")) {
                        Button(action: shutdownServer) {
                            HStack {
                                Image(systemName: "power")
                                Text("Shutdown Server")
                            }
                            .foregroundColor(.red)
                        }
                        
                        Button(action: restartServer) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("Restart Server")
                            }
                        }
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
    
    private func shutdownServer() {
        guard let url = URL(string: "http://\(raspberryPiIP):5000/shutdown") else {
            showError("Invalid server URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    showError(error.localizedDescription)
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse,
                   httpResponse.statusCode == 200 {
                    alertTitle = "Success"
                    alertMessage = "Server shutdown initiated"
                    showAlert = true
                } else {
                    showError("Server shutdown failed")
                }
            }
        }.resume()
    }
    
    private func restartServer() {
        guard let url = URL(string: "http://\(raspberryPiIP):5000/restart") else {
            showError("Invalid server URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    showError(error.localizedDescription)
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse,
                   httpResponse.statusCode == 200 {
                    alertTitle = "Success"
                    alertMessage = "Server restart initiated"
                    showAlert = true
                } else {
                    showError("Server restart failed")
                }
            }
        }.resume()
    }
    
    private func showError(_ message: String) {
        alertTitle = "Error"
        alertMessage = message
        showAlert = true
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
    
    // Logout function
    private func logout() {
        // Clear stored credentials (in a real app, also clear keychain)
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
    }
}

#Preview {
    SettingsView()
}