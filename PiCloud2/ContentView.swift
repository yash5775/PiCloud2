//
//  ContentView.swift
//  PiCloud2
//
//  Created by Chaniyara Yash on 12/05/25.
//

import SwiftUI

struct ContentView: View {
    @State private var searchText = ""
    @State private var isToggleOn = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ResponsiveContainer {
                    VStack(spacing: HIGConstants.Spacing.large) {
                        // Header section with proper typography
                        VStack(spacing: HIGConstants.Spacing.medium) {
                            Image(systemName: "cloud")
                                .font(.system(size: 60))
                                .foregroundColor(AppColors.primary)
                                .frame(minWidth: HIGConstants.minimumTouchTargetSize, minHeight: HIGConstants.minimumTouchTargetSize)
                                .padding()
                            
                            Text("Welcome to PiCloud")
                                .titleStyle()
                            
                            Text("Your personal cloud storage solution")
                                .captionStyle()
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        
                        // Search field with proper touch target size
                        AppTextField(placeholder: "Search files", text: $searchText)
                        
                        // Card examples with proper spacing and contrast
                        CardView {
                            VStack(alignment: .leading, spacing: HIGConstants.Spacing.medium) {
                                Text("Quick Access")
                                    .headlineStyle()
                                
                                HStack(spacing: HIGConstants.Spacing.medium) {
                                    ForEach(["doc.fill", "photo", "video", "music.note"], id: \.self) { icon in
                                        VStack {
                                            Image(systemName: icon)
                                                .font(.system(size: 24))
                                                .foregroundColor(AppColors.primary)
                                                .frame(width: HIGConstants.minimumTouchTargetSize, height: HIGConstants.minimumTouchTargetSize)
                                                .background(AppColors.secondaryBackground)
                                                .cornerRadius(HIGConstants.CornerRadius.small)
                                            
                                            Text(iconName(for: icon))
                                                .captionStyle()
                                        }
                                    }
                                }
                            }
                        }
                        
                        // List items with proper touch targets
                        VStack(spacing: 0) {
                            Text("Recent Files")
                                .headlineStyle()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.bottom, HIGConstants.Spacing.small)
                            
                            ForEach(["Document.pdf", "Image.jpg", "Presentation.key"], id: \.self) { filename in
                                ListItemView {
                                    HStack {
                                        Image(systemName: iconForFile(filename))
                                            .foregroundColor(AppColors.primary)
                                        
                                        Text(filename)
                                            .bodyStyle()
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(AppColors.secondaryLabel)
                                    }
                                }
                            }
                        }
                        
                        // Settings section with toggle
                        VStack(alignment: .leading, spacing: HIGConstants.Spacing.medium) {
                            Text("Settings")
                                .headlineStyle()
                            
                            AppToggle(title: "Enable Notifications", isOn: $isToggleOn)
                        }
                        
                        // Buttons with proper styling
                        HStack(spacing: HIGConstants.Spacing.medium) {
                            Button("Upload") {}
                                .buttonStyle(PrimaryButtonStyle())
                                .frame(maxWidth: .infinity)
                            
                            Button("Share") {}
                                .buttonStyle(SecondaryButtonStyle())
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.vertical, HIGConstants.Spacing.large)
                }
            }
            .navigationTitle("PiCloud")
            .background(AppColors.background)
        }
    }
    
    // Helper functions
    private func iconName(for systemName: String) -> String {
        switch systemName {
        case "doc.fill": return "Documents"
        case "photo": return "Photos"
        case "video": return "Videos"
        case "music.note": return "Audio"
        default: return ""
        }
    }
    
    private func iconForFile(_ filename: String) -> String {
        if filename.hasSuffix(".pdf") {
            return "doc.fill"
        } else if filename.hasSuffix(".jpg") || filename.hasSuffix(".png") {
            return "photo"
        } else if filename.hasSuffix(".key") {
            return "chart.bar.doc.horizontal"
        } else {
            return "doc"
        }
    }
}

#Preview {
    ContentView()
}
