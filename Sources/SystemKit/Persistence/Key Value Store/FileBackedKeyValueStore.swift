//
//  Copyright © 2017 Apparata AB. All rights reserved.
//

import Foundation

/// A file-backed persistent implementation of ``KeyValueStore``.
///
/// `FileBackedKeyValueStore` stores key-value pairs in a property list file,
/// automatically persisting changes to disk and using file locking for thread safety.
///
/// ## Overview
///
/// This implementation:
/// - Automatically saves to disk on every change
/// - Loads existing data on initialization
/// - Uses file locking to prevent concurrent access issues
/// - Supports transactions for batching multiple changes
///
/// ## Usage
///
/// ```swift
/// let storePath = Path.documentDirectory!
///     .appendingComponent("settings.plist").string
/// let store = FileBackedKeyValueStore(path: storePath)
///
/// // Changes are automatically persisted
/// store["theme"] = "dark"
/// store["fontSize"] = 14
///
/// // Use transactions for multiple changes
/// try store.transaction { store in
///     store["key1"] = "value1"
///     store["key2"] = "value2"
///     store["key3"] = "value3"
///     // All changes persisted at once when transaction completes
/// }
/// ```
///
/// - Note: Each write operation triggers a save to disk. Use ``transaction(actions:)``
///         for better performance when making multiple changes.
open class FileBackedKeyValueStore: KeyValueStore {

    /// The underlying dictionary storing all key-value pairs.
    ///
    /// This property is read-only from outside the class but can be
    /// accessed for inspection or serialization.
    private(set) var dictionary: [String: Any] = [:]

    private let path: String

    /// Creates a file-backed key-value store at the specified path.
    ///
    /// If a file exists at the path, it will be loaded. Otherwise, an empty
    /// store is created and will be saved to the path on the first write.
    ///
    /// - Parameter path: The file path where data should be persisted
    public init(path: String) {
        self.path = path
        dictionary = restore()
    }

    /// Performs multiple changes in a transaction, persisting only once.
    ///
    /// Use transactions to improve performance when making multiple changes,
    /// as the store is only written to disk once at the end of the transaction.
    ///
    /// - Parameter actions: A closure that performs the desired changes
    /// - Throws: Any error from the persist operation or from the actions closure
    ///
    /// ## Example
    ///
    /// ```swift
    /// try store.transaction { store in
    ///     store["name"] = "Alice"
    ///     store["age"] = 30
    ///     store["city"] = "Portland"
    /// }
    /// ```
    public func transaction(actions: (KeyValueStore) throws -> Void) throws {
        let keyValueStore = MemoryBackedKeyValueStore(dictionary: dictionary)
        try actions(self)
        lock()
        do {
            try persist(dictionary: keyValueStore.dictionary)
        } catch let error as NSError {
            print("Error persisting key value store: \(error.localizedDescription)")
            unlock()
            throw error
        }
        dictionary = keyValueStore.dictionary
        unlock()
    }
    
    /// Object
    public subscript(key: String) -> Any? {
        get {
            lock()
            let value = dictionary[key]
            unlock()
            return value
        }
        set(newValue) {
            if let value = newValue {
                dictionary[key] = value
            } else {
                dictionary.removeValue(forKey: key)
            }
            persist()
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
            lock()
            let value = dictionary[key] as? [Any]
            unlock()
            return value
        }
        set(newValue) {
            if let value = newValue {
                dictionary[key] = value
            } else {
                dictionary.removeValue(forKey: key)
            }
            persist()
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
            lock()
            let value = dictionary[key] as? [String: Any]
            unlock()
            return value
        }
        set(newValue) {
            if let value = newValue {
                dictionary[key] = value
            } else {
                dictionary.removeValue(forKey: key)
            }
            persist()
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
            lock()
            let value = dictionary[key] as? String
            unlock()
            return value
        }
        set(newValue) {
            if let value = newValue {
                dictionary[key] = value
            } else {
                dictionary.removeValue(forKey: key)
            }
            persist()
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
            lock()
            let value = dictionary[key] as? [String]
            unlock()
            return value
        }
        set(newValue) {
            if let value = newValue {
                dictionary[key] = value
            } else {
                dictionary.removeValue(forKey: key)
            }
            persist()
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
            lock()
            let value = dictionary[key] as? Data
            unlock()
            return value
        }
        set(newValue) {
            if let value = newValue {
                dictionary[key] = value
            } else {
                dictionary.removeValue(forKey: key)
            }
            persist()
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
            lock()
            let value = dictionary[key] as? Bool
            unlock()
            return value
        }
        set(newValue) {
            if let value = newValue {
                dictionary[key] = value
            } else {
                dictionary.removeValue(forKey: key)
            }
            persist()
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
            lock()
            let value = dictionary[key] as? Int
            unlock()
            return value
        }
        set(newValue) {
            if let value = newValue {
                dictionary[key] = value
            } else {
                dictionary.removeValue(forKey: key)
            }
            persist()
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
            lock()
            let value = dictionary[key] as? Float
            unlock()
            return value
        }
        set(newValue) {
            if let value = newValue {
                dictionary[key] = value
            } else {
                dictionary.removeValue(forKey: key)
            }
            persist()
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
            lock()
            let value = dictionary[key] as? Double
            unlock()
            return value
        }
        set(newValue) {
            lock()
            if let value = newValue {
                dictionary[key] = value
            } else {
                dictionary.removeValue(forKey: key)
            }
            persist()
            unlock()
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
            lock()
            let value = dictionary[key] as? URL
            unlock()
            return value
        }
        set(newValue) {
            lock()
            if let value = newValue {
                dictionary[key] = value
            } else {
                dictionary.removeValue(forKey: key)
            }
            persist()
            unlock()
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
            lock()
            let value = dictionary[key] as? Date
            unlock()
            return value
        }
        set(newValue) {
            lock()
            if let value = newValue {
                dictionary[key] = value
            } else {
                dictionary.removeValue(forKey: key)
            }
            persist()
            unlock()
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
            lock()
            if let value = newValue {
                dictionary[key] = value.identifier
            } else {
                dictionary.removeValue(forKey: key)
            }
            unlock()
        }
    }
    
    public subscript(key: String, default: Locale) -> Locale {
        get {
            return self[key] ?? `default`
        }
    }
    
    // MARK: - Peristence
    
    private func restore() -> [String: Any] {
        do {
            if FileManager.default.fileExists(atPath: path) {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                if let dictionary = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] {
                    return dictionary
                }
            } else {
                return [:]
            }
        } catch let error as NSError {
            print("Error restoring key value store: \(error.localizedDescription)")
        }
        return [:]
    }
    
    private func persist() {
        do {
            try persist(dictionary: dictionary)
        } catch let error as NSError {
            print("Error persisting key value store: \(error.localizedDescription)")
        }
    }
    
    private func persist(dictionary: [String: Any]) throws {
        let data = try PropertyListSerialization.data(fromPropertyList: dictionary, format: .binary, options: 0)
        let url = URL(fileURLWithPath: path)
        try data.write(to: url, options: [.atomic])
    }
    
    // MARK: - Thread Safety
    
    private func lock() {
        objc_sync_enter(self)
    }
    
    private func unlock() {
        objc_sync_exit(self)
    }
}
