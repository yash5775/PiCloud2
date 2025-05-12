//
//  UIComponents.swift
//  PiCloud2
//
//  Created for PiCloud2 project
//

import SwiftUI

// MARK: - Design Constants
struct HIGConstants {
    // Minimum touch target size (44x44 points)
    static let minimumTouchTargetSize: CGFloat = 44
    
    // Text sizes following Apple HIG
    struct FontSize {
        static let largeTitle: CGFloat = 34
        static let title1: CGFloat = 28
        static let title2: CGFloat = 22
        static let title3: CGFloat = 20
        static let headline: CGFloat = 17
        static let body: CGFloat = 17
        static let callout: CGFloat = 16
        static let subheadline: CGFloat = 15
        static let footnote: CGFloat = 13
        static let caption1: CGFloat = 12
        static let caption2: CGFloat = 11 // Minimum readable size per HIG
    }
    
    // Standard spacing values
    struct Spacing {
        static let xSmall: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let xLarge: CGFloat = 32
        static let xxLarge: CGFloat = 48
    }
    
    // Standard corner radius values
    struct CornerRadius {
        static let small: CGFloat = 6
        static let medium: CGFloat = 10
        static let large: CGFloat = 16
        static let extraLarge: CGFloat = 24
    }
}

// MARK: - Color Theme
struct AppColors {
    // System colors that adapt to light/dark mode
    static let primary = Color.accentColor
    static let secondary = Color("SecondaryColor")
    static let background = Color(UIColor.systemBackground)
    static let secondaryBackground = Color(UIColor.secondarySystemBackground)
    static let groupedBackground = Color(UIColor.systemGroupedBackground)
    static let label = Color(UIColor.label)
    static let secondaryLabel = Color(UIColor.secondaryLabel)
    static let tertiaryLabel = Color(UIColor.tertiaryLabel)
    
    // Semantic colors
    static let success = Color.green
    static let warning = Color.yellow
    static let error = Color.red
    static let info = Color.blue
}

// MARK: - Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(minWidth: HIGConstants.minimumTouchTargetSize, minHeight: HIGConstants.minimumTouchTargetSize)
            .background(AppColors.primary)
            .foregroundColor(.white)
            .cornerRadius(HIGConstants.CornerRadius.medium)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(minWidth: HIGConstants.minimumTouchTargetSize, minHeight: HIGConstants.minimumTouchTargetSize)
            .background(AppColors.secondaryBackground)
            .foregroundColor(AppColors.primary)
            .cornerRadius(HIGConstants.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: HIGConstants.CornerRadius.medium)
                    .stroke(AppColors.primary, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
    }
}

// MARK: - Text Styles
extension View {
    func titleStyle() -> some View {
        self.font(.system(size: HIGConstants.FontSize.title1, weight: .bold))
            .foregroundColor(AppColors.label)
    }
    
    func headlineStyle() -> some View {
        self.font(.system(size: HIGConstants.FontSize.headline, weight: .semibold))
            .foregroundColor(AppColors.label)
    }
    
    func bodyStyle() -> some View {
        self.font(.system(size: HIGConstants.FontSize.body))
            .foregroundColor(AppColors.label)
    }
    
    func captionStyle() -> some View {
        self.font(.system(size: HIGConstants.FontSize.caption1))
            .foregroundColor(AppColors.secondaryLabel)
    }
}

// MARK: - Card View
struct CardView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(HIGConstants.Spacing.medium)
            .background(AppColors.secondaryBackground)
            .cornerRadius(HIGConstants.CornerRadius.medium)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - List Item
struct ListItemView<Content: View>: View {
    let content: Content
    let showDivider: Bool
    
    init(showDivider: Bool = true, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.showDivider = showDivider
    }
    
    var body: some View {
        VStack(spacing: 0) {
            content
                .padding(HIGConstants.Spacing.medium)
                .frame(minHeight: HIGConstants.minimumTouchTargetSize)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            
            if showDivider {
                Divider()
                    .padding(.leading, HIGConstants.Spacing.medium)
            }
        }
        .background(AppColors.background)
    }
}

// MARK: - Input Field
struct AppTextField: View {
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: HIGConstants.Spacing.xSmall) {
            if isSecure {
                SecureField(placeholder, text: $text)
                    .padding()
                    .frame(height: HIGConstants.minimumTouchTargetSize)
                    .background(AppColors.secondaryBackground)
                    .cornerRadius(HIGConstants.CornerRadius.small)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .padding()
                    .frame(height: HIGConstants.minimumTouchTargetSize)
                    .background(AppColors.secondaryBackground)
                    .cornerRadius(HIGConstants.CornerRadius.small)
            }
        }
    }
}

// MARK: - Toggle Switch
struct AppToggle: View {
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        Toggle(isOn: $isOn) {
            Text(title)
                .bodyStyle()
        }
        .toggleStyle(SwitchToggleStyle(tint: AppColors.primary))
    }
}

// MARK: - Responsive Layout
struct ResponsiveContainer<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geometry in
            if geometry.size.width < 600 { // Phone
                content
                    .padding(HIGConstants.Spacing.medium)
            } else { // iPad or larger
                content
                    .padding(HIGConstants.Spacing.large)
                    .frame(maxWidth: 800)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}