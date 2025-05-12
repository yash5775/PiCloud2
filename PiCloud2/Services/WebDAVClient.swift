//
//  WebDAVClient.swift
//  PiCloud2
//
//  Created for PiCloud project
//

import Foundation

/// Service class for communicating with WebDAV servers
class WebDAVClient {
    // MARK: - Properties
    
    /// The base URL of the WebDAV server
    private let serverURL: URL
    
    /// Username for authentication
    private let username: String
    
    /// Password for authentication
    private let password: String
    
    // MARK: - Initialization
    
    /// Initialize with server URL and credentials
    /// - Parameters:
    ///   - serverURL: The base URL of the WebDAV server
    ///   - username: Username for authentication
    ///   - password: Password for authentication
    init(serverURL: String, username: String, password: String) throws {
        guard let url = URL(string: serverURL) else {
            throw WebDAVError.invalidURL
        }
        
        self.serverURL = url
        self.username = username
        self.password = password
    }
    
    // MARK: - Public Methods
    
    /// List files and folders at the specified path
    /// - Parameter path: The path to list (defaults to root)
    /// - Returns: An array of FileItem objects
    func listFiles(at path: String = "/") async throws -> [FileItem] {
        // Create the request URL
        let requestURL = serverURL.appendingPathComponent(path)
        
        // Create the request
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PROPFIND"
        request.setValue("1", forHTTPHeaderField: "Depth")
        request.setValue("application/xml", forHTTPHeaderField: "Content-Type")
        
        // Add authentication
        let authString = "\(username):\(password)"
        if let authData = authString.data(using: .utf8) {
            let base64Auth = authData.base64EncodedString()
            request.setValue("Basic \(base64Auth)", forHTTPHeaderField: "Authorization")
        }
        
        // Set the request body (PROPFIND XML)
        let propfindXML = """
        <?xml version="1.0" encoding="utf-8" ?>
        <D:propfind xmlns:D="DAV:">
            <D:prop>
                <D:resourcetype/>
                <D:getcontentlength/>
                <D:getlastmodified/>
                <D:displayname/>
            </D:prop>
        </D:propfind>
        """
        request.httpBody = propfindXML.data(using: .utf8)
        
        // Send the request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Check response status
        guard let httpResponse = response as? HTTPURLResponse else {
            throw WebDAVError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299, 207: // 207 is Multi-Status response for PROPFIND
            // Parse the XML response
            return try parseWebDAVResponse(data, basePath: path)
        case 401:
            throw WebDAVError.authenticationFailed
        case 404:
            throw WebDAVError.notFound
        default:
            throw WebDAVError.serverError(statusCode: httpResponse.statusCode)
        }
    }
    
    /// Download a file from the WebDAV server
    /// - Parameter fileItem: The FileItem to download
    /// - Returns: The downloaded data
    func downloadFile(_ fileItem: FileItem) async throws -> Data {
        // Create the request URL
        let requestURL = serverURL.appendingPathComponent(fileItem.path)
        
        // Create the request
        var request = URLRequest(url: requestURL)
        request.httpMethod = "GET"
        
        // Add authentication
        let authString = "\(username):\(password)"
        if let authData = authString.data(using: .utf8) {
            let base64Auth = authData.base64EncodedString()
            request.setValue("Basic \(base64Auth)", forHTTPHeaderField: "Authorization")
        }
        
        // Send the request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Check response status
        guard let httpResponse = response as? HTTPURLResponse else {
            throw WebDAVError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return data
        case 401:
            throw WebDAVError.authenticationFailed
        case 404:
            throw WebDAVError.notFound
        default:
            throw WebDAVError.serverError(statusCode: httpResponse.statusCode)
        }
    }
    
    /// Upload a file to the WebDAV server
    /// - Parameters:
    ///   - data: The file data to upload
    ///   - fileName: The name of the file
    ///   - path: The path to upload to (defaults to root)
    func uploadFile(_ data: Data, fileName: String, to path: String = "/") async throws {
        // Create the full path including filename
        let fullPath = path.hasSuffix("/") ? "\(path)\(fileName)" : "\(path)/\(fileName)"
        
        // Create the request URL
        let requestURL = serverURL.appendingPathComponent(fullPath)
        
        // Create the request
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        request.httpBody = data
        
        // Add authentication
        let authString = "\(username):\(password)"
        if let authData = authString.data(using: .utf8) {
            let base64Auth = authData.base64EncodedString()
            request.setValue("Basic \(base64Auth)", forHTTPHeaderField: "Authorization")
        }
        
        // Send the request
        let (_, response) = try await URLSession.shared.data(for: request)
        
        // Check response status
        guard let httpResponse = response as? HTTPURLResponse else {
            throw WebDAVError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return
        case 401:
            throw WebDAVError.authenticationFailed
        default:
            throw WebDAVError.serverError(statusCode: httpResponse.statusCode)
        }
    }
    
    // MARK: - Private Methods
    
    /// Parse the WebDAV XML response
    /// - Parameters:
    ///   - data: The XML data to parse
    ///   - basePath: The base path of the request
    /// - Returns: An array of FileItem objects
    private func parseWebDAVResponse(_ data: Data, basePath: String) throws -> [FileItem] {
        // In a real implementation, this would use XMLParser to parse the response
        // For now, return mock data
        return FileItem.mockItems
    }
}

/// Enum representing WebDAV errors
enum WebDAVError: Error {
    case invalidURL
    case authenticationFailed
    case invalidResponse
    case notFound
    case serverError(statusCode: Int)
    case parsingError
}