//
//  DashboardView.swift
//  PiCloud2
//
//  Created for PiCloud project
//

import SwiftUI
import UniformTypeIdentifiers

struct DashboardView: View {
    @AppStorage("username") private var username = ""
    @AppStorage("serverURL") private var serverURL = ""
    
    @State private var files: [FileItem] = []
    @State private var isLoading = false
    @State private var searchText = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var currentPath = "/"
    @State private var showSettings = false
    @State private var showDocumentPicker = false
    @State private var selectedFileForDownload: FileItem? = nil
    @State private var isDownloading = false
    
    // Keychain helper for retrieving credentials
    private let keychainHelper = KeychainHelper()
    
    var filteredFiles: [FileItem] {
        if searchText.isEmpty {
            return files
        } else {
            return files.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationStack {
            ResponsiveContainer {
                VStack(spacing: HIGConstants.Spacing.medium) {
                    // Search bar
                    AppTextField(placeholder: "Search files", text: $searchText)
                    
                    // Current path indicator
                    HStack {
                        Button(action: {
                            navigateToParentFolder()
                        }) {
                            Image(systemName: "arrow.left")
                                .frame(minWidth: HIGConstants.minimumTouchTargetSize, minHeight: HIGConstants.minimumTouchTargetSize)
                        }
                        .disabled(currentPath == "/")
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                Text(currentPath)
                                    .font(.subheadline)
                                    .foregroundColor(AppColors.secondaryLabel)
                            }
                        }
                    }
                    
                    if isLoading {
                        Spacer()
                        ProgressView("Loading files...")
                            .progressViewStyle(CircularProgressViewStyle())
                        Spacer()
                    } else if files.isEmpty {
                        Spacer()
                        VStack(spacing: HIGConstants.Spacing.medium) {
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.system(size: 50))
                                .foregroundColor(AppColors.secondaryLabel)
                            
                            Text("No files found")
                                .font(.headline)
                            
                            Text("Upload a file to get started")
                                .font(.subheadline)
                                .foregroundColor(AppColors.secondaryLabel)
                                .multilineTextAlignment(.center)
                            
                            Button(action: {
                                showDocumentPicker = true
                            }) {
                                HStack {
                                    Image(systemName: "arrow.up.doc")
                                    Text("Upload File")
                                }
                                .frame(minWidth: HIGConstants.minimumTouchTargetSize, minHeight: HIGConstants.minimumTouchTargetSize)
                            }
                            .buttonStyle(PrimaryButtonStyle())
                            .padding(.top)
                        }
                        Spacer()
                    } else {
                        // File list
                        List {
                            ForEach(filteredFiles) { item in
                                FileItemRow(item: item, onTap: {
                                    if item.type == .folder {
                                        navigateToFolder(item)
                                    }
                                }, onDownload: {
                                    selectedFileForDownload = item
                                    downloadFile(item)
                                })
                            }
                        }
                        .listStyle(PlainListStyle())
                        .background(AppColors.background)
                    }
                }
                .padding()
            }
            .navigationTitle("My Files")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showDocumentPicker = true
                    }) {
                        Image(systemName: "arrow.up.doc")
                            .frame(minWidth: HIGConstants.minimumTouchTargetSize, minHeight: HIGConstants.minimumTouchTargetSize)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showSettings = true
                    }) {
                        Image(systemName: "gear")
                            .frame(minWidth: HIGConstants.minimumTouchTargetSize, minHeight: HIGConstants.minimumTouchTargetSize)
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showDocumentPicker) {
                DocumentPicker(onDocumentPicked: uploadFile)
            }
            .onAppear {
                loadFiles()
            }
            .overlay {
                if isDownloading {
                    ZStack {
                        Color.black.opacity(0.4)
                            .edgesIgnoringSafeArea(.all)
                        
                        VStack {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .scaleEffect(1.5)
                            
                            Text("Downloading...")
                                .font(.headline)
                                .padding(.top)
                        }
                        .padding(HIGConstants.Spacing.large)
                        .background(AppColors.background)
                        .cornerRadius(HIGConstants.CornerRadius.large)
                    }
                }
            }
        }
    }
    
    private func loadFiles() {
        isLoading = true
        
        // Get credentials from keychain
        do {
            let password = try keychainHelper.retrieve(for: username)
            
            // Create WebDAV client
            let webDAVClient = try WebDAVClient(serverURL: serverURL, username: username, password: password)
            
            // Load files from WebDAV server
            Task {
                do {
                    let loadedFiles = try await webDAVClient.listFiles(at: currentPath)
                    DispatchQueue.main.async {
                        files = loadedFiles
                        isLoading = false
                    }
                } catch {
                    DispatchQueue.main.async {
                        // For now, use mock data if there's an error
                        files = FileItem.mockItems
                        isLoading = false
                        
                        // Show error message
                        errorMessage = "Failed to load files: \(error.localizedDescription)"
                        showError = true
                    }
                }
            }
        } catch {
            // Fall back to mock data if credentials can't be retrieved
            DispatchQueue.main.async {
                files = FileItem.mockItems
                isLoading = false
                
                errorMessage = "Failed to retrieve credentials: \(error.localizedDescription)"
                showError = true
            }
        }
    }
    
    private func navigateToFolder(_ folder: FileItem) {
        currentPath = folder.path
        loadFiles()
    }
    
    private func navigateToParentFolder() {
        guard currentPath != "/" else { return }
        
        let components = currentPath.split(separator: "/")
        if components.count <= 1 {
            currentPath = "/"
        } else {
            currentPath = "/" + components.dropLast().joined(separator: "/")
        }
        
        loadFiles()
    }
    
    private func uploadFile(_ url: URL) {
        guard let data = try? Data(contentsOf: url) else {
            errorMessage = "Failed to read file data"
            showError = true
            return
        }
        
        let fileName = url.lastPathComponent
        
        // Get credentials from keychain
        do {
            let password = try keychainHelper.retrieve(for: username)
            
            // Create WebDAV client
            let webDAVClient = try WebDAVClient(serverURL: serverURL, username: username, password: password)
            
            // Upload file to WebDAV server
            Task {
                do {
                    try await webDAVClient.uploadFile(data, fileName: fileName, to: currentPath)
                    
                    // Reload files after upload
                    DispatchQueue.main.async {
                        loadFiles()
                    }
                } catch {
                    DispatchQueue.main.async {
                        errorMessage = "Failed to upload file: \(error.localizedDescription)"
                        showError = true
                    }
                }
            }
        } catch {
            errorMessage = "Failed to retrieve credentials: \(error.localizedDescription)"
            showError = true
        }
    }
    
    private func downloadFile(_ file: FileItem) {
        isDownloading = true
        
        // Get credentials from keychain
        do {
            let password = try keychainHelper.retrieve(for: username)
            
            // Create WebDAV client
            let webDAVClient = try WebDAVClient(serverURL: serverURL, username: username, password: password)
            
            // Download file from WebDAV server
            Task {
                do {
                    let data = try await webDAVClient.downloadFile(file)
                    
                    // Save file to local storage
                    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    let fileURL = documentsDirectory.appendingPathComponent(file.name)
                    
                    try data.write(to: fileURL)
                    
                    DispatchQueue.main.async {
                        isDownloading = false
                        
                        // Show success message
                        errorMessage = "File downloaded successfully"
                        showError = true
                    }
                } catch {
                    DispatchQueue.main.async {
                        isDownloading = false
                        
                        errorMessage = "Failed to download file: \(error.localizedDescription)"
                        showError = true
                    }
                }
            }
        } catch {
            DispatchQueue.main.async {
                isDownloading = false
                
                errorMessage = "Failed to retrieve credentials: \(error.localizedDescription)"
                showError = true
            }
        }
    }
}

// Row component for displaying a file or folder item
struct FileItemRow: View {
    let item: FileItem
    let onTap: () -> Void
    let onDownload: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: HIGConstants.Spacing.medium) {
                // Icon
                Image(systemName: item.type.iconName)
                    .font(.title2)
                    .foregroundColor(item.type == .folder ? AppColors.primary : AppColors.secondary)
                    .frame(width: HIGConstants.minimumTouchTargetSize, height: HIGConstants.minimumTouchTargetSize)
                
                // File details
                VStack(alignment: .leading, spacing: HIGConstants.Spacing.xSmall) {
                    Text(item.name)
                        .font(.headline)
                        .foregroundColor(AppColors.label)
                    
                    if item.type == .file {
                        Text(item.formattedSize)
                            .font(.caption)
                            .foregroundColor(AppColors.secondaryLabel)
                    }
                }
                
                Spacer()
                
                // Action buttons for files
                if item.type == .file {
                    Button(action: onDownload) {
                        Image(systemName: "arrow.down.circle")
                            .font(.title3)
                            .foregroundColor(AppColors.primary)
                            .frame(minWidth: HIGConstants.minimumTouchTargetSize, minHeight: HIGConstants.minimumTouchTargetSize)
                    }
                }
            }
            .padding(.vertical, HIGConstants.Spacing.small)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Document picker for file uploads
struct DocumentPicker: UIViewControllerRepresentable {
    let onDocumentPicked: (URL) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.item], asCopy: true)
        picker.allowsMultipleSelection = false
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            parent.onDocumentPicked(url)
        }
    }
}

#Preview {
    DashboardView()
}