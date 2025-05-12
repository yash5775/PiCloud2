//
//  PiCloudApp.swift
//  PiCloud2
//
//  Created for PiCloud project
//

import SwiftUI

@main
struct PiCloudApp: App {
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    
    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                DashboardView()
            } else {
                LoginView()
            }
        }
    }
}