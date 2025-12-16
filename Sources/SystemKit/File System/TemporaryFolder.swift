//
//  Copyright © 2016 Apparata AB. All rights reserved.
//

import Foundation

/// Manages a unique temporary folder in the caches directory with automatic cleanup.
///
/// `TemporaryFolder` provides a convenient way to create isolated temporary storage
/// that is automatically deleted when no longer needed. By default, the folder is
/// removed when the object is deallocated.
///
/// ## Overview
///
/// Temporary folders are created in the system caches directory and are ideal for:
/// - Processing temporary files
/// - Staging downloads before moving to permanent storage
/// - Isolated workspaces for file operations
///
/// ## Usage
///
/// ```swift
/// // Create with automatic cleanup
/// let tempFolder = TemporaryFolder(create: true)
/// let workFile = tempFolder.url(forResource: "work", ofType: "dat")
/// // Process files...
/// // Folder automatically deleted when tempFolder is deallocated
///
/// // Create with manual cleanup
/// let manualFolder = TemporaryFolder(deleteAutomatically: false)
/// try manualFolder.create()
/// // ... use folder ...
/// try manualFolder.delete()  // Manual cleanup
/// ```
public class TemporaryFolder {

    /// URL of the app caches folder.
    private static var cacheFolderURL: URL {
        let filemanager = FileManager.default
        // Force unwrap, because there MUST be a caches directory.
        return filemanager.urls(for: .cachesDirectory, in: .userDomainMask).last!
    }

    /// Unique name of the temporary folder.
    private let name: String

    /// The URL of the temporary folder.
    public let url: URL

    /// The path of the temporary folder as a string.
    public var path: String {
        return url.path
    }

    /// Controls whether the folder is automatically deleted on deallocation.
    ///
    /// Set to `false` if you want to manage the folder's lifecycle manually.
    public var deleteAutomatically: Bool

    /// Creates a new temporary folder manager.
    ///
    /// - Parameters:
    ///   - name: Optional custom name for the folder. If `nil`, a UUID is generated
    ///   - create: If `true`, creates the folder immediately
    ///   - deleteAutomatically: If `true`, deletes the folder when deallocated (default)
    public init(name: String? = nil, create: Bool = false, deleteAutomatically: Bool = true) {
        
        self.deleteAutomatically = deleteAutomatically
        
        self.name = name ?? UUID().uuidString
        
        url = TemporaryFolder.cacheFolderURL.appendingPathComponent(self.name, isDirectory: true)
        
        if create {
            try? self.create()
        }
    }
    
    deinit {
        if deleteAutomatically {
            try? delete()
        }
    }
    
    /// Creates the temporary folder if it doesn't already exist.
    ///
    /// - Throws: An error if the folder cannot be created
    public func create() throws {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: path) {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
    }

    /// Deletes the temporary folder if it exists.
    ///
    /// - Throws: An error if the folder cannot be deleted
    public func delete() throws {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path) {
            try fileManager.removeItem(at: url)
        }
    }

    /// Checks whether a specific resource file exists in the temporary folder.
    ///
    /// - Parameters:
    ///   - resource: The base name of the resource (without extension)
    ///   - type: The file extension
    /// - Returns: `true` if the file exists, `false` otherwise
    public func exists(resource: String, ofType type: String) -> Bool {
        let fileManager = FileManager.default
        return fileManager.fileExists(atPath: path(forResource: resource, ofType: type))
    }

    /// Checks whether a specific resource file exists in a subdirectory of the temporary folder.
    ///
    /// - Parameters:
    ///   - resource: The base name of the resource (without extension)
    ///   - type: The file extension
    ///   - directory: The subdirectory name
    /// - Returns: `true` if the file exists, `false` otherwise
    public func exists(resource: String, ofType type: String, inDirectory directory: String) -> Bool {
        let fileManager = FileManager.default
        return fileManager.fileExists(atPath: path(forResource: resource, ofType: type, inDirectory: directory))
    }

    /// Returns the path for a resource file in the temporary folder.
    ///
    /// - Parameters:
    ///   - resource: The base name of the resource (without extension)
    ///   - ofType: The file extension
    /// - Returns: The full path to the resource
    public func path(forResource resource: String, ofType: String) -> String {
        // There is really no reason for why the path would be nil.
        return url.appendingPathComponent(resource + "." + ofType).path
    }

    /// Returns the path for a resource file in a subdirectory of the temporary folder.
    ///
    /// - Parameters:
    ///   - resource: The base name of the resource (without extension)
    ///   - ofType: The file extension
    ///   - inDirectory: The subdirectory name
    /// - Returns: The full path to the resource
    public func path(forResource resource: String, ofType: String, inDirectory: String) -> String {
        // There is really no reason for why the path would be nil.
        return url.appendingPathComponent(inDirectory).appendingPathComponent(resource + "." + ofType).path
    }

    /// Returns the URL for a resource file in the temporary folder.
    ///
    /// - Parameters:
    ///   - resource: The base name of the resource (without extension)
    ///   - ofType: The file extension
    /// - Returns: The URL of the resource
    public func url(forResource resource: String, ofType: String) -> URL {
        return url.appendingPathComponent(resource + "." + ofType)
    }

    /// Returns the URL for a resource file in a subdirectory of the temporary folder.
    ///
    /// - Parameters:
    ///   - resource: The base name of the resource (without extension)
    ///   - ofType: The file extension
    ///   - inDirectory: The subdirectory name
    /// - Returns: The URL of the resource
    public func url(forResource resource: String, ofType: String, inDirectory: String) -> URL {
        return url.appendingPathComponent(inDirectory).appendingPathComponent(resource + "." + ofType)
    }
    
}
