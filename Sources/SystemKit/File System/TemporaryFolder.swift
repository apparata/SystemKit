//
//  Copyright © 2016 Apparata AB. All rights reserved.
//

import Foundation

/// TemporaryFolder represents a folder in the caches directory that is
/// unique and removed when the object is deallocated (by default).
public class TemporaryFolder {
    
    /// URL of the app caches folder.
    private static var cacheFolderURL: URL {
        let filemanager = FileManager.default
        // Force unwrap, because there MUST be a caches directory.
        return filemanager.urls(for: .cachesDirectory, in: .userDomainMask).last!
    }
    
    /// Unique name of the temporary folder.
    private let name: String
    
    /// URL of the temporary folder.
    public let url: URL
    
    /// Path of the temporary folder.
    public var path: String {
        return url.path
    }
    
    public var deleteAutomatically: Bool
    
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
    
    /// Creates the temporary folder, if it does not already exist.
    public func create() throws {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: path) {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    /// Deletes the temporary folder.
    public func delete() throws {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path) {
            try fileManager.removeItem(at: url)
        }
    }
    
    public func exists(resource: String, ofType type: String) -> Bool {
        let fileManager = FileManager.default
        return fileManager.fileExists(atPath: path(forResource: resource, ofType: type))
    }
    
    public func exists(resource: String, ofType type: String, inDirectory directory: String) -> Bool {
        let fileManager = FileManager.default
        return fileManager.fileExists(atPath: path(forResource: resource, ofType: type, inDirectory: directory))
    }
    
    /// Returns the path of a resource in the temporary folder.
    public func path(forResource resource: String, ofType: String) -> String {
        // There is really no reason for why the path would be nil.
        return url.appendingPathComponent(resource + "." + ofType).path
    }
    
    /// Returns the path of a resource in the temporary folder in a subdirectory.
    public func path(forResource resource: String, ofType: String, inDirectory: String) -> String {
        // There is really no reason for why the path would be nil.
        return url.appendingPathComponent(inDirectory).appendingPathComponent(resource + "." + ofType).path
    }
    
    /// Returns the URL of a resource in the temporary folder.
    public func url(forResource resource: String, ofType: String) -> URL {
        return url.appendingPathComponent(resource + "." + ofType)
    }
    
    /// Returns the URL of a resource in the temporary folder in a subdirectory.
    public func url(forResource resource: String, ofType: String, inDirectory: String) -> URL {
        return url.appendingPathComponent(inDirectory).appendingPathComponent(resource + "." + ofType)
    }
    
}
