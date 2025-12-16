//
//  Copyright © 2017 Apparata AB. All rights reserved.
//

import Foundation

/// A protocol for read-only access to type-safe key-value storage.
///
/// `ReadOnlyKeyValueStore` provides subscript-based access to stored values with
/// automatic type conversion. Each type has two subscript variants:
/// - Optional return: `store[key] -> Type?`
/// - Default value: `store[key, default: value] -> Type`
///
/// ## Supported Types
///
/// - `Any` - Untyped objects
/// - `[Any]` - Arrays of any type
/// - `[String: Any]` - Dictionaries
/// - `String` - Strings
/// - `[String]` - String arrays
/// - `Data` - Binary data
/// - `Bool` - Booleans
/// - `Int` - Integers
/// - `Float` - Floating-point numbers
/// - `Double` - Double-precision numbers
/// - `URL` - URLs
/// - `Date` - Dates
/// - `Locale` - Locales
public protocol ReadOnlyKeyValueStore {

    /// Retrieves an object value for the specified key.
    ///
    /// - Parameter key: The key to look up
    /// - Returns: The stored value, or `nil` if not found
    subscript(key: String) -> Any? { get }

    /// Retrieves an object value for the specified key, with a default.
    ///
    /// - Parameters:
    ///   - key: The key to look up
    ///   - default: The value to return if the key is not found
    /// - Returns: The stored value, or the default if not found
    subscript(key: String, default: Any) -> Any { get }

    /// Array
    subscript(key: String) -> [Any]? { get }
    subscript(key: String, default: [Any]) -> [Any] { get }

    /// Dictionary
    subscript(key: String) -> [String: Any]? { get }
    subscript(key: String, default: [String: Any]) -> [String: Any] { get }

    /// String
    subscript(key: String) -> String? { get }
    subscript(key: String, default: String) -> String { get }

    /// Array of strings
    subscript(key: String) -> [String]? { get }
    subscript(key: String, default: [String]) -> [String] { get }

    /// Data
    subscript(key: String) -> Data? { get }
    subscript(key: String, default: Data) -> Data { get }

    /// Bool
    subscript(key: String) -> Bool? { get }
    subscript(key: String, default: Bool) -> Bool { get }

    /// Int
    subscript(key: String) -> Int? { get }
    subscript(key: String, default: Int) -> Int { get }

    /// Float
    subscript(key: String) -> Float? { get }
    subscript(key: String, default: Float) -> Float { get }

    /// Double
    subscript(key: String) -> Double? { get }
    subscript(key: String, default: Double) -> Double { get }

    /// URL
    subscript(key: String) -> URL? { get }
    subscript(key: String, default: URL) -> URL { get }

    /// Date
    subscript(key: String) -> Date? { get }
    subscript(key: String, default: Date) -> Date { get }

    /// Locale
    subscript(key: String) -> Locale? { get }
    subscript(key: String, default: Locale) -> Locale { get }
}

/// A protocol for read-write access to type-safe key-value storage.
///
/// `KeyValueStore` extends ``ReadOnlyKeyValueStore`` with write capabilities.
/// Setting a value to `nil` removes that key from the store.
///
/// ## Usage
///
/// ```swift
/// var store: KeyValueStore = MemoryBackedKeyValueStore()
///
/// // Store values
/// store["username"] = "alice"
/// store["age"] = 30
/// store["isPremium"] = true
///
/// // Retrieve values
/// let name: String? = store["username"]
/// let age = store["age", default: 0]
///
/// // Remove values
/// store["username"] = nil
/// ```
///
/// ## Implementations
///
/// SystemKit provides two implementations:
/// - ``MemoryBackedKeyValueStore`` - In-memory storage
/// - ``FileBackedKeyValueStore`` - File-backed persistent storage
public protocol KeyValueStore: ReadOnlyKeyValueStore {

    /// Gets or sets an object value for the specified key.
    ///
    /// Setting to `nil` removes the key from the store.
    subscript(key: String) -> Any? { get set }

    /// Gets or sets an array value for the specified key.
    ///
    /// Setting to `nil` removes the key from the store.
    subscript(key: String) -> [Any]? { get set }

    /// Gets or sets a dictionary value for the specified key.
    ///
    /// Setting to `nil` removes the key from the store.
    subscript(key: String) -> [String: Any]? { get set }

    /// Gets or sets a string value for the specified key.
    ///
    /// Setting to `nil` removes the key from the store.
    subscript(key: String) -> String? { get set }

    /// Gets or sets a string array value for the specified key.
    ///
    /// Setting to `nil` removes the key from the store.
    subscript(key: String) -> [String]? { get set }

    /// Gets or sets binary data for the specified key.
    ///
    /// Setting to `nil` removes the key from the store.
    subscript(key: String) -> Data? { get set }
    
    /// Bool
    subscript(key: String) -> Bool? { get set }
    
    /// Int
    subscript(key: String) -> Int? { get set }
    
    /// Float
    subscript(key: String) -> Float? { get set }
    
    /// Double
    subscript(key: String) -> Double? { get set }
    
    /// URL
    subscript(key: String) -> URL? { get set }
    
    /// Date
    subscript(key: String) -> Date? { get set }
    
    /// Locale
    subscript(key: String) -> Locale? { get set }
}


