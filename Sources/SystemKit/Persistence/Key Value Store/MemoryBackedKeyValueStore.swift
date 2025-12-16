//
//  Copyright © 2017 Apparata AB. All rights reserved.
//

import Foundation

/// An in-memory implementation of ``KeyValueStore``.
///
/// `MemoryBackedKeyValueStore` stores all values in a dictionary in memory.
/// Data is not persisted and will be lost when the instance is deallocated.
///
/// ## Overview
///
/// This implementation is useful for:
/// - Temporary storage during app execution
/// - Testing without file system dependencies
/// - Caching data that doesn't need persistence
///
/// ## Usage
///
/// ```swift
/// // Create empty store
/// let store = MemoryBackedKeyValueStore()
/// store["count"] = 42
///
/// // Create with initial values
/// let initialData = ["name": "Alice", "age": 30]
/// let preloadedStore = MemoryBackedKeyValueStore(dictionary: initialData)
/// ```
///
/// - Note: For persistent storage, use ``FileBackedKeyValueStore`` instead
open class MemoryBackedKeyValueStore: KeyValueStore {

    /// The underlying dictionary storing all key-value pairs.
    ///
    /// This property is read-only from outside the class but can be
    /// accessed for inspection or serialization.
    private(set) var dictionary: [String: Any] = [:]

    /// Creates an empty in-memory key-value store.
    public init() { }

    /// Creates an in-memory key-value store with initial values.
    ///
    /// - Parameter dictionary: Initial key-value pairs to populate the store
    public init(dictionary: [String: Any]) {
        self.dictionary = dictionary
    }
    
    /// Object
    public subscript(key: String) -> Any? {
        get {
            return dictionary[key]
        }
        set(newValue) {
            if let value = newValue {
                dictionary[key] = value
            } else {
                dictionary.removeValue(forKey: key)
            }
        }
    }
    
    public subscript(key: String, default: Any) -> Any {
        get {
            return self[key] ?? `default`
        }
    }
    
    /// Array
    public subscript(key: String) -> [Any]? {
        get {
            return dictionary[key] as? [Any]
        }
        set(newValue) {
            if let value = newValue {
                dictionary[key] = value
            } else {
                dictionary.removeValue(forKey: key)
            }
        }
    }
    
    public subscript(key: String, default: [Any]) -> [Any] {
        get {
            return self[key] ?? `default`
        }
    }
    
    /// Dictionary
    public subscript(key: String) -> [String: Any]? {
        get {
            return dictionary[key] as? [String: Any]
        }
        set(newValue) {
            if let value = newValue {
                dictionary[key] = value
            } else {
                dictionary.removeValue(forKey: key)
            }
        }
    }
    
    public subscript(key: String, default: [String: Any]) -> [String: Any] {
        get {
            return self[key] ?? `default`
        }
    }
    
    /// String
    public subscript(key: String) -> String? {
        get {
            return dictionary[key] as? String
        }
        set(newValue) {
            if let value = newValue {
                dictionary[key] = value
            } else {
                dictionary.removeValue(forKey: key)
            }
        }
    }
    
    public subscript(key: String, default: String) -> String {
        get {
            return self[key] ?? `default`
        }
    }
    
    /// Array of strings
    public subscript(key: String) -> [String]? {
        get {
            return dictionary[key] as? [String]
        }
        set(newValue) {
            if let value = newValue {
                dictionary[key] = value
            } else {
                dictionary.removeValue(forKey: key)
            }
        }
    }
    
    public subscript(key: String, default: [String]) -> [String] {
        get {
            return self[key] ?? `default`
        }
    }
    
    /// Data
    public subscript(key: String) -> Data? {
        get {
            return dictionary[key] as? Data
        }
        set(newValue) {
            if let value = newValue {
                dictionary[key] = value
            } else {
                dictionary.removeValue(forKey: key)
            }
        }
    }
    
    public subscript(key: String, default: Data) -> Data {
        get {
            return self[key] ?? `default`
        }
    }
    
    /// Bool
    public subscript(key: String) -> Bool? {
        get {
            return dictionary[key] as? Bool
        }
        set(newValue) {
            if let value = newValue {
                dictionary[key] = value
            } else {
                dictionary.removeValue(forKey: key)
            }
        }
    }
    
    public subscript(key: String, default: Bool) -> Bool {
        get {
            return self[key] ?? `default`
        }
    }
    
    /// Int
    public subscript(key: String) -> Int? {
        get {
            return dictionary[key] as? Int
        }
        set(newValue) {
            if let value = newValue {
                dictionary[key] = value
            } else {
                dictionary.removeValue(forKey: key)
            }
        }
    }
    
    public subscript(key: String, default: Int) -> Int {
        get {
            return self[key] ?? `default`
        }
    }
    
    /// Float
    public subscript(key: String) -> Float? {
        get {
            return dictionary[key] as? Float
        }
        set(newValue) {
            if let value = newValue {
                dictionary[key] = value
            } else {
                dictionary.removeValue(forKey: key)
            }
        }
    }
    
    public subscript(key: String, default: Float) -> Float {
        get {
            return self[key] ?? `default`
        }
    }
    
    /// Double
    public subscript(key: String) -> Double? {
        get {
            return dictionary[key] as? Double
        }
        set(newValue) {
            if let value = newValue {
                dictionary[key] = value
            } else {
                dictionary.removeValue(forKey: key)
            }
        }
    }
    
    public subscript(key: String, default: Double) -> Double {
        get {
            return self[key] ?? `default`
        }
    }
    
    /// URL
    public subscript(key: String) -> URL? {
        get {
            return dictionary[key] as? URL
        }
        set(newValue) {
            if let value = newValue {
                dictionary[key] = value
            } else {
                dictionary.removeValue(forKey: key)
            }
        }
    }
    
    public subscript(key: String, default: URL) -> URL {
        get {
            return self[key] ?? `default`
        }
    }
    
    /// Date
    public subscript(key: String) -> Date? {
        get {
            return dictionary[key] as? Date
        }
        set(newValue) {
            if let value = newValue {
                dictionary[key] = value
            } else {
                dictionary.removeValue(forKey: key)
            }
        }
    }
    
    public subscript(key: String, default: Date) -> Date {
        get {
            return self[key] ?? `default`
        }
    }
    
    /// Locale
    public subscript(key: String) -> Locale? {
        get {
            if let localeIdentifier: String = self[key] {
                return Locale(identifier: localeIdentifier)
            }
            return nil
        }
        set(newValue) {
            if let value = newValue {
                dictionary[key] = value.identifier
            } else {
                dictionary.removeValue(forKey: key)
            }
        }
    }
    
    public subscript(key: String, default: Locale) -> Locale {
        get {
            return self[key] ?? `default`
        }
    }
}
