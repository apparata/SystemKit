//
//  Copyright © 2017 Apparata AB. All rights reserved.
//

import Foundation

open class FileBackedKeyValueStore: KeyValueStore {

    private(set) var dictionary: [String: Any] = [:]
    
    private let path: String
    
    public init(path: String) {
        self.path = path
        dictionary = restore()
    }
    
    /// Use transaction if you only want to write the store to file once
    /// for a number of changes, as opposed to for every change.
    /// Transaction throws if persist operation fails.
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
