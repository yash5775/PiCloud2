//
//  ContentView.swift
//  PiCloud
//
//  Created by Chaniyara Yash on 12/05/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "cloud")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .foregroundStyle(.blue)
                    .accessibilityLabel("PiCloud logo")
                
                Text("Welcome to PiCloud")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                    .accessibilityAddTraits(.isHeader)
                
                Text("Your personal cloud storage solution")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                Spacer().frame(height: 20)
                
                NavigationLink(destination: LoginView()) {
                    HStack {
                        Text("Sign In")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .frame(minWidth: 200, minHeight: 44) // Ensures minimum 44pt hit target
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
                    .accessibilityIdentifier("signInButton")
                }
                
                Button(action: {}) {
                    Text("Create Account")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(minWidth: 200, minHeight: 44) // Ensures minimum 44pt hit target
                        .background(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.blue, lineWidth: 2)
                        )
                        .accessibilityIdentifier("createAccountButton")
                }
            }
            .padding(.vertical, 40)
            .frame(maxWidth: .infinity)
            .background(Color(UIColor.systemBackground))
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    ContentView()
}
