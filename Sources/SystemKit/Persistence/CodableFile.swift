//
//  Copyright © 2021 Apparata AB. All rights reserved.
//

import Foundation

enum CodableFileError: Error {
    case noSuchFile
}

/// Simple persistence of codable object.
public class CodableFile {
    
    private let queue = DispatchQueue(label: "systemkit.codablefile", qos: .userInitiated)
    
    private let path: Path

    public init(path: Path) {
        self.path = path
    }
    
    /// Loads synchronously
    public func load<T: Decodable>(completion: @escaping (Result<T, Error>) -> Void) {
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
    
    /// Loads synchronously
    public func loadSynchronously<T: Decodable>() throws -> T {
        guard path.exists else {
            throw CodableFileError.noSuchFile
        }
        let json = try Data(contentsOf: path.url)
        let object = try JSONDecoder().decode(T.self, from: json)
        return object
    }
    
    /// Saves asynchronously
    public func save<T: Codable>(_ object: T) {
        queue.async { [path] in
            do {
                let json = try JSONEncoder().encode(object)
                try json.write(to: path.url, options: .atomic)
            } catch {
                dump(error)
            }
        }
    }
    
    /// Saves synchronously
    public func saveSynchronously<T: Codable>(_ object: T) throws {
        let json = try JSONEncoder().encode(object)
        try json.write(to: path.url, options: .atomic)
    }
}
