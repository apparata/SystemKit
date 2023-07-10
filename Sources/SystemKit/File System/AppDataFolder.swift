//
//  Copyright © 2016 Apparata AB. All rights reserved.
//

import Foundation

enum AppDataFolderError: Error {
    case noSuchFile
    case fileAlreadyExists
}

/// AppDataFolder represents a folder in the documents directory that is
/// marked as a resource that should not be backed up. It is meant for
/// app data that can be recreated, as opposed to user data.
public class AppDataFolder {

    /// URL of the documents folder.
    public static var documentsFolder: URL {
        if #available(iOS 16, macOS 13, tvOS 16, *) {
            return URL.documentsDirectory
        } else {
            let fileManager = FileManager.default
            // Force unwrap, because there MUST be a document directory.
            return fileManager.urls(for: .documentDirectory, in: .userDomainMask).last!
        }
    }

    /// URL of the app data folder.
    public static var url: URL {
        return documentsFolder.appendingPathComponent("appData", isDirectory: true)
    }

    /// Path of the app data folder.
    public static var path: String {
        return url.path
    }
    
    public static var exists: Bool {
        return FileManager.default.fileExists(atPath: path)
    }

    /// Creates the app data folder, if it does not already exist.
    public static func create() throws {
        let fileManager = FileManager.default
        try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        try excludeFromBackup(fileURL: AppDataFolder.url)
    }
    
    /// Returns full path
    public static func createSubfolder(name: String) throws {
        let subfolderURL = urlForSubfolder(name: name)
        let fileManager = FileManager.default
        try create()
        try fileManager.createDirectory(at: subfolderURL, withIntermediateDirectories: true, attributes: nil)
    }

    public static func urlForSubfolder(name: String) -> URL {
        let subfolderURL = url.appendingPathComponent(name)
        return subfolderURL
    }
    
    public static func pathForSubfolder(name: String) -> String {
        let path = urlForSubfolder(name: name).path
        return path
    }

    /// Throws AppDataFolderError or NSError depending on error.
    private static func excludeFromBackup(path: String) throws {
        let url = URL(fileURLWithPath: path)
        try excludeFromBackup(fileURL: url)
    }

    /// Throws AppDataFolderError or NSError depending on error.
    private static func excludeFromBackup(fileURL: URL) throws {
        let fileManager = FileManager.default

        guard fileManager.fileExists(atPath: fileURL.path) else {
            throw AppDataFolderError.noSuchFile
        }
        
        let mutableURL: NSURL = fileURL as NSURL

        try mutableURL.setResourceValue(true, forKey: URLResourceKey.isExcludedFromBackupKey)
    }

    /// Returns the path of a resource in the app data folder.
    public static func pathForResource(resource: String, ofType: String) -> String {
        // There is really no reason for why the path would be nil.
        return url.appendingPathComponent(resource + "." + ofType).path
    }

    /// Returns the path of a resource in the app data folder in a subdirectory.
    public static func pathForResource(resource: String, ofType: String, inDirectory: String) -> String {
        // There is really no reason for why the path would be nil.
        return url.appendingPathComponent(inDirectory).appendingPathComponent(resource + "." + ofType).path
    }

    /// Returns the URL of a resource in the app data folder.
    public static func urlForResource(resource: String, ofType: String) -> URL {
        return url.appendingPathComponent(resource + "." + ofType)
    }

    /// Returns the URL of a resource in the app data folder in a subdirectory.
    public static func urlForResource(resource: String, ofType: String, inDirectory: String) -> URL {
        return url.appendingPathComponent(inDirectory).appendingPathComponent(resource + "." + ofType)
    }
}
