//
//  Copyright © 2016 Apparata AB. All rights reserved.
//

import Foundation

enum AppDataFolderError: Error {
    case noSuchFile
    case fileAlreadyExists
}

/// Manages a dedicated folder in the documents directory for recreatable app data.
///
/// `AppDataFolder` provides a centralized location for storing application data that
/// can be regenerated if necessary. Unlike user documents, this folder is automatically
/// marked to be excluded from iCloud and iTunes backups to save backup space.
///
/// ## Overview
///
/// The app data folder is located at `~/Documents/appData/` and is ideal for:
/// - Downloaded resources that can be re-downloaded
/// - Cached processing results
/// - Application state that can be recreated
///
/// ## Usage
///
/// ```swift
/// // Create the app data folder
/// try AppDataFolder.create()
///
/// // Get a path to a file in the app data folder
/// let dataPath = AppDataFolder.pathForResource(resource: "config", ofType: "json")
///
/// // Create a subfolder
/// try AppDataFolder.createSubfolder(name: "downloads")
/// ```
///
/// - Important: User-created documents should NOT be stored in this folder as they
///              are excluded from backups. Use the standard documents directory for
///              user data.
public class AppDataFolder {

    /// The URL of the user's documents folder.
    public static var documentsFolder: URL {
        if #available(iOS 16, macOS 13, tvOS 16, *) {
            return URL.documentsDirectory
        } else {
            let fileManager = FileManager.default
            // Force unwrap, because there MUST be a document directory.
            return fileManager.urls(for: .documentDirectory, in: .userDomainMask).last!
        }
    }

    /// The URL of the app data folder.
    ///
    /// This is located at `~/Documents/appData/`.
    public static var url: URL {
        return documentsFolder.appendingPathComponent("appData", isDirectory: true)
    }

    /// The path of the app data folder as a string.
    public static var path: String {
        return url.path
    }

    /// Indicates whether the app data folder currently exists.
    public static var exists: Bool {
        return FileManager.default.fileExists(atPath: path)
    }

    /// Creates the app data folder if it doesn't already exist.
    ///
    /// The created folder is automatically marked to be excluded from iCloud
    /// and iTunes backups.
    ///
    /// - Throws: An error if the folder cannot be created or marked for exclusion
    public static func create() throws {
        let fileManager = FileManager.default
        try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        try excludeFromBackup(fileURL: AppDataFolder.url)
    }
    
    /// Creates a subfolder within the app data folder.
    ///
    /// This ensures the parent app data folder exists before creating the subfolder.
    ///
    /// - Parameter name: The name of the subfolder to create
    /// - Throws: An error if the folder cannot be created
    public static func createSubfolder(name: String) throws {
        let subfolderURL = urlForSubfolder(name: name)
        let fileManager = FileManager.default
        try create()
        try fileManager.createDirectory(at: subfolderURL, withIntermediateDirectories: true, attributes: nil)
    }

    /// Returns the URL for a subfolder in the app data folder.
    ///
    /// - Parameter name: The name of the subfolder
    /// - Returns: The URL of the subfolder
    ///
    /// - Note: This does not check if the subfolder exists or create it
    public static func urlForSubfolder(name: String) -> URL {
        let subfolderURL = url.appendingPathComponent(name)
        return subfolderURL
    }

    /// Returns the path for a subfolder in the app data folder.
    ///
    /// - Parameter name: The name of the subfolder
    /// - Returns: The path of the subfolder as a string
    ///
    /// - Note: This does not check if the subfolder exists or create it
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

    /// Returns the path for a file resource in the app data folder.
    ///
    /// - Parameters:
    ///   - resource: The base name of the resource (without extension)
    ///   - ofType: The file extension
    /// - Returns: The full path to the resource
    public static func pathForResource(resource: String, ofType: String) -> String {
        // There is really no reason for why the path would be nil.
        return url.appendingPathComponent(resource + "." + ofType).path
    }

    /// Returns the path for a file resource in a subdirectory of the app data folder.
    ///
    /// - Parameters:
    ///   - resource: The base name of the resource (without extension)
    ///   - ofType: The file extension
    ///   - inDirectory: The subdirectory name
    /// - Returns: The full path to the resource
    public static func pathForResource(resource: String, ofType: String, inDirectory: String) -> String {
        // There is really no reason for why the path would be nil.
        return url.appendingPathComponent(inDirectory).appendingPathComponent(resource + "." + ofType).path
    }

    /// Returns the URL for a file resource in the app data folder.
    ///
    /// - Parameters:
    ///   - resource: The base name of the resource (without extension)
    ///   - ofType: The file extension
    /// - Returns: The URL of the resource
    public static func urlForResource(resource: String, ofType: String) -> URL {
        return url.appendingPathComponent(resource + "." + ofType)
    }

    /// Returns the URL for a file resource in a subdirectory of the app data folder.
    ///
    /// - Parameters:
    ///   - resource: The base name of the resource (without extension)
    ///   - ofType: The file extension
    ///   - inDirectory: The subdirectory name
    /// - Returns: The URL of the resource
    public static func urlForResource(resource: String, ofType: String, inDirectory: String) -> URL {
        return url.appendingPathComponent(inDirectory).appendingPathComponent(resource + "." + ofType)
    }
}
