//
//  Copyright © 2021 Apparata AB. All rights reserved.
//

import Foundation

public enum CodableFileError: Error {
    case noSuchFile
}

/// Provides simple JSON-based persistence for `Codable` objects.
///
/// `CodableFile` handles serialization and deserialization of Codable types to/from
/// JSON files, with support for both asynchronous and synchronous operations.
///
/// ## Overview
///
/// This class provides a straightforward way to persist and load Swift `Codable` types
/// without dealing with `JSONEncoder`/`JSONDecoder` directly.
///
/// ## Usage
///
/// ```swift
/// struct AppSettings: Codable {
///     var theme: String
///     var notifications: Bool
/// }
///
/// let settingsPath = Path.documentDirectory!.appendingComponent("settings.json")
/// let codableFile = CodableFile(path: settingsPath)
///
/// // Save asynchronously
/// let settings = AppSettings(theme: "dark", notifications: true)
/// codableFile.save(settings)
///
/// // Load synchronously
/// let loadedSettings: AppSettings = try codableFile.loadSynchronously()
///
/// // Load asynchronously
/// codableFile.load { (result: Result<AppSettings, Error>) in
///     switch result {
///     case .success(let settings):
///         print("Loaded: \(settings)")
///     case .failure(let error):
///         print("Error: \(error)")
///     }
/// }
/// ```
public class CodableFile {

    private let queue = DispatchQueue(label: "systemkit.codablefile", qos: .userInitiated)

    private let path: Path

    /// Creates a new codable file manager for a specific path.
    ///
    /// - Parameter path: The file path where the JSON data will be stored
    public init(path: Path) {
        self.path = path
    }

    /// Loads a codable object from the file asynchronously.
    ///
    /// - Parameter completion: A closure called on the main queue with the result
    ///
    /// - Note: Despite the name, this method loads on a background queue and returns
    ///         the result asynchronously via the completion handler
    public func load<T: Sendable & Decodable>(completion: @escaping @Sendable (Result<T, Error>) -> Void) {
        queue.async { [path] in
            do {
                guard path.exists else {
                    throw CodableFileError.noSuchFile
                }
                let json = try Data(contentsOf: path.url)
                let object = try JSONDecoder().decode(T.self, from: json)
                DispatchQueue.main.async {
                    completion(.success(object))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    /// Loads a codable object from the file synchronously.
    ///
    /// This method blocks the calling thread until the file is loaded and decoded.
    ///
    /// - Returns: The decoded object
    /// - Throws: `CodableFileError.noSuchFile` if the file doesn't exist, or decoding errors
    public func loadSynchronously<T: Decodable>() throws -> T {
        guard path.exists else {
            throw CodableFileError.noSuchFile
        }
        let json = try Data(contentsOf: path.url)
        let object = try JSONDecoder().decode(T.self, from: json)
        return object
    }

    /// Saves a codable object to the file asynchronously.
    ///
    /// The object is encoded to JSON and written atomically on a background queue.
    /// Errors during encoding or writing are dumped to the console.
    ///
    /// - Parameter object: The object to save
    public func save<T: Sendable & Codable>(_ object: T) {
        queue.async { [path] in
            do {
                let json = try JSONEncoder().encode(object)
                try json.write(to: path.url, options: .atomic)
            } catch {
                dump(error)
            }
        }
    }

    /// Saves a codable object to the file synchronously.
    ///
    /// This method blocks the calling thread until the file is written.
    /// The write is performed atomically.
    ///
    /// - Parameter object: The object to save
    /// - Throws: An error if encoding or writing fails
    public func saveSynchronously<T: Codable>(_ object: T) throws {
        let json = try JSONEncoder().encode(object)
        try json.write(to: path.url, options: .atomic)
    }
}
