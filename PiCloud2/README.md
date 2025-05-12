# PiCloud - Personal Cloud Manager

## Project Overview

PiCloud is an iOS app that allows users to access and manage files stored on a self-hosted WebDAV server (like Nextcloud). The app supports file uploads/downloads, Siri Shortcuts integration for smart plug control, and optional HomeKit support.

## Project Structure

### Views

- **LoginView**: Handles user authentication with WebDAV server
- **DashboardView**: Displays files and folders from the WebDAV server
- **SettingsView**: Contains app configuration and smart home controls

### Models

- **FileItem**: Represents files and folders with properties like name, type, and size
- **UserSettings**: Manages user preferences and server configuration

### Services

- **WebDAVClient**: Handles communication with WebDAV servers
- **KeychainHelper**: Securely stores user credentials
- **ServerController**: Manages server shutdown/restart functionality

### Helpers

- **BiometricAuthHelper**: Manages Face ID/Touch ID authentication
- **FileFormatter**: Formats file sizes and types for display

## Features

- WebDAV server connection
- Secure credential storage
- File browsing, upload, and download
- Smart plug control via Siri Shortcuts
- Optional HomeKit integration
- Biometric authentication
- Server power management

## Implementation Plan

1. Set up project structure
2. Create login screen
3. Implement secure credential storage
4. Build dashboard UI
5. Connect to WebDAV server
6. Add file upload/download functionality
7. Integrate Siri Shortcuts
8. Add HomeKit support (optional)
9. Implement server control options
10. Add biometric authentication
11. Polish UI and finalize

## Design Guidelines

This project follows Apple's Human Interface Guidelines (HIG) to ensure a consistent, intuitive, and visually appealing user experience.
