//
//  FileItem.swift
//  PiCloud2
//
//  Created for PiCloud project
//

import Foundation

/// Model representing a file or folder item from the WebDAV server
struct FileItem: Identifiable {
    /// Unique identifier for the item
    var id = UUID()
    
    /// Name of the file or folder
    var name: String
    
    /// Type of the item ("file" or "folder")
    var type: ItemType
    
    /// Size of the file in bytes (0 for folders)
    var size: Int
    
    /// Last modified date of the item
    var modifiedDate: Date?
    
    /// Full path of the item on the server
    var path: String
    
    /// Enum representing the type of item
    enum ItemType: String {
        case file
        case folder
        
        /// Returns the appropriate SF Symbol name for the item type
        var iconName: String {
            switch self {
            case .file:
                return "doc"
            case .folder:
                return "folder"
            }
        }
    }
    
    /// Formatted file size (e.g., "1.2 MB")
    var formattedSize: String {
        if type == .folder {
            return ""
        }
        
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(size))
    }
}

/// Helper extension for creating mock data
extension FileItem {
    static var mockItems: [FileItem] = [
        FileItem(name: "Documents", type: .folder, size: 0, path: "/Documents"),
        FileItem(name: "Photos", type: .folder, size: 0, path: "/Photos"),
        FileItem(name: "report.pdf", type: .file, size: 1_250_000, modifiedDate: Date(), path: "/report.pdf"),
        FileItem(name: "presentation.key", type: .file, size: 5_600_000, modifiedDate: Date(), path: "/presentation.key"),
        FileItem(name: "budget.xlsx", type: .file, size: 350_000, modifiedDate: Date(), path: "/budget.xlsx"),
        FileItem(name: "profile.jpg", type: .file, size: 2_800_000, modifiedDate: Date(), path: "/profile.jpg")
    ]
}