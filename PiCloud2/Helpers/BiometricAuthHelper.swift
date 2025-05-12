//
//  BiometricAuthHelper.swift
//  PiCloud2
//
//  Created for PiCloud project
//

import LocalAuthentication
import Foundation

/// Helper class for handling biometric authentication (Face ID / Touch ID)
class BiometricAuthHelper {
    
    /// Enum representing different biometric types
    enum BiometricType {
        case none
        case touchID
        case faceID
        
        /// Returns a user-friendly name for the biometric type
        var name: String {
            switch self {
            case .none: return "None"
            case .touchID: return "Touch ID"
            case .faceID: return "Face ID"
            }
        }
    }
    
    /// Enum representing authentication errors
    enum AuthenticationError: Error {
        case notAvailable
        case notEnrolled
        case noCredentials
        case userCancel
        case authenticationFailed
        case biometryLockout
        case unknown
        
        /// Returns a user-friendly error message
        var message: String {
            switch self {
            case .notAvailable:
                return "Biometric authentication is not available on this device."
            case .notEnrolled:
                return "No biometric authentication methods are enrolled."
            case .noCredentials:
                return "No credentials are available for authentication."
            case .userCancel:
                return "Authentication was canceled by the user."
            case .authenticationFailed:
                return "Authentication failed."
            case .biometryLockout:
                return "Biometric authentication is locked out due to too many failed attempts."
            case .unknown:
                return "An unknown error occurred during authentication."
            }
        }
    }
    
    /// Get the available biometric type on the device
    /// - Returns: The available BiometricType
    static func getBiometricType() -> BiometricType {
        let context = LAContext()
        var error: NSError?
        
        // Check if biometric authentication is available
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            if #available(iOS 11.0, *) {
                switch context.biometryType {
                case .touchID:
                    return .touchID
                case .faceID:
                    return .faceID
                default:
                    return .none
                }
            } else {
                // Before iOS 11, only Touch ID was available
                return .touchID
            }
        }
        
        return .none
    }
    
    /// Authenticate using biometrics
    /// - Parameters:
    ///   - reason: The reason for authentication to display to the user
    ///   - completion: Completion handler with result and optional error
    static func authenticate(reason: String = "Authenticate to access your files", completion: @escaping (Bool, AuthenticationError?) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        // Check if biometric authentication is available
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            // Perform authentication
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
                DispatchQueue.main.async {
                    if success {
                        completion(true, nil)
                    } else {
                        // Handle authentication errors
                        if let error = error as? LAError {
                            switch error.code {
                            case .userCancel:
                                completion(false, .userCancel)
                            case .userFallback:
                                completion(false, .userCancel)
                            case .biometryNotAvailable:
                                completion(false, .notAvailable)
                            case .biometryNotEnrolled:
                                completion(false, .notEnrolled)
                            case .biometryLockout:
                                completion(false, .biometryLockout)
                            case .authenticationFailed:
                                completion(false, .authenticationFailed)
                            default:
                                completion(false, .unknown)
                            }
                        } else {
                            completion(false, .unknown)
                        }
                    }
                }
            }
        } else {
            // Biometric authentication is not available
            if let error = error as? LAError {
                switch error.code {
                case .biometryNotAvailable:
                    completion(false, .notAvailable)
                case .biometryNotEnrolled:
                    completion(false, .notEnrolled)
                default:
                    completion(false, .unknown)
                }
            } else {
                completion(false, .unknown)
            }
        }
    }
}