//
//  Copyright © 2017 Apparata AB. All rights reserved.
//

import Foundation

public protocol ReadOnlyKeyValueStore {
    
    /// Object
    subscript(key: String) -> Any? { get }
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

public protocol KeyValueStore: ReadOnlyKeyValueStore {
    
    /// Object
    subscript(key: String) -> Any? { get set }
    
    /// Array
    subscript(key: String) -> [Any]? { get set }
    
    /// Dictionary
    subscript(key: String) -> [String: Any]? { get set }
    
    /// String
    subscript(key: String) -> String? { get set }
    
    /// Array of strings
    subscript(key: String) -> [String]? { get set }
    
    /// Data
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


