//
//  Copyright © 2016 Apparata AB. All rights reserved.
//

import Foundation

/// Represents a file system path.
///
/// - Example:
/// ```
/// let absolutePath = Path("/usr/bin/zip")
/// absolutePath.isAbsolute
/// absolutePath.isRelative
///
/// let relativePath = Path("bin/whatever")
/// relativePath.isAbsolute
/// relativePath.isRelative
///
/// let concatenatedPath = Path("/usr") + Path("/bin")
///
/// let messyPath = Path("//usr/../usr/local/bin/./whatever")
/// messyPath.normalized
///
/// let pathFromLiteralString: Path = "/this/is/a/path"
/// let pathFromEmptyString: Path = ""
/// let pathFromConcatenatedStrings: Path = "/usr" + "/bin"
///
/// let pathFromComponents = Path(components: ["/", "usr/", "bin", "/", "swift"])
/// let pathFromEmptyComponents = Path(components: [])
///
/// let appendedPath = Path("/usr/local").appendingComponent("bin")
/// let appendedPath3 = Path("/usr/local").appending(Path("bin"))
/// let appendedPath2 = Path("/usr/local") + Path("bin")
///
/// let imagePath = Path("photos/photo").appendingExtension("jpg")
/// imagePath.extension
///
/// let imagePathWithoutExtension = imagePath.deletingExtension
/// let imagePathWithoutLastComponent = imagePath.deletingLastComponent
///
/// absolutePath.exists
/// absolutePath.isFile
/// absolutePath.isDirectory
/// absolutePath.isDeletable
/// absolutePath.isExecutable
/// absolutePath.isReadable
/// absolutePath.isWritable
/// ```
public struct Path {
    
    fileprivate var path: String
    
    var internalPath: String {
        return path
    }
        
    public var isAbsolute: Bool {
        return path.first == "/"
    }
    
    public var isRelative: Bool {
        return !isAbsolute
    }
    
    public var normalized: Path {
        return Path((path as NSString).standardizingPath)
    }
    
    public var string: String {
        return path
    }
    
    public var url: URL {
        return URL(fileURLWithPath: path)
    }
    
    public init() {
        path = "."
    }
    
    public init(_ path: String) {
        if path.isEmpty {
            self.path = "."
        } else {
            self.path = path
        }
    }
    
    public func appending(_ path: Path) -> Path {
        return Path((self.path as NSString).appendingPathComponent(path.path))
    }
    
    public init<T: Collection>(components: T) where T.Iterator.Element == String {
        if components.isEmpty {
            path = "."
        } else {
            let strings: [String] = components.map { $0 }
            path = NSString.path(withComponents: strings)
        }
    }
    
    public var lastComponent: String {
        return (path as NSString).lastPathComponent
    }
    
    public var deletingLastComponent: Path {
        return Path((path as NSString).deletingLastPathComponent)
    }
    
    public func appendingComponent(_ string: String) -> Path {
        return Path((path as NSString).appendingPathComponent(string))
    }
    
    public func replacingLastComponent(with string: String) -> Path {
        return deletingLastComponent.appendingComponent(string)
    }
    
    public var `extension`: String {
        return (path as NSString).pathExtension
    }
    
    public var deletingExtension: Path {
        return Path((path as NSString).deletingPathExtension)
    }
    
    public func appendingExtension(_ string: String) -> Path {
        guard let newPath = (path as NSString).appendingPathExtension(string) else {
            // Not sure what could cause it to be nil, so here's a fallback plan.
            return Path(path + "." + string)
        }
        return Path(newPath)
    }
    
    public func replacingExtension(with string: String) -> Path {
        return deletingExtension.appendingExtension(string)
    }
}

// MARK: - Object Description

extension Path: CustomStringConvertible {
    public var description: String {
        return path
    }
}

// MARK: - String Literal Convertible

extension Path: ExpressibleByStringLiteral {
    public typealias UnicodeScalarLiteralType = StringLiteralType
    public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
    
    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        path = "\(value)"
        if path.isEmpty {
            path = "."
        }
    }
    
    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        path = value
        if path.isEmpty {
            path = "."
        }
    }
    
    public init(stringLiteral value: StringLiteralType) {
        path = value
        if path.isEmpty {
            path = "."
        }
    }
}

// MARK: - Hashable, Equatable, Comparable

extension Path: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(path)
    }
}

extension Path: Equatable {
    
    public static func ==(lhs: Path, rhs: Path) -> Bool {
        return lhs.path == rhs.path
    }
}

extension Path : Comparable {
 
    public static func <(lhs: Path, rhs: Path) -> Bool {
        return lhs.path < rhs.path
    }
}

// MARK: - Concatenation

public func +(lhs: Path, rhs: Path) -> Path {
    return lhs.appending(rhs)
}

public func +(lhs: Path, rhs: String) -> Path {
    return lhs.appendingComponent(rhs)
}

// MARK: - File Management Operations

public extension Path {
    
    fileprivate static var fileManager: FileManager {
        return FileManager.default
    }
    
    fileprivate var fileManager: FileManager {
        return FileManager.default
    }
    
    /// Note: No-op if file does not exist.
    func excludeFromBackup() throws {
        guard exists else {
            return
        }
        
        let mutableURL: NSURL = url as NSURL
        
        try mutableURL.setResourceValue(true, forKey: URLResourceKey.isExcludedFromBackupKey)
    }
    
    var exists: Bool {
        return fileManager.fileExists(atPath: internalPath)
    }
    
    var doesNotExist: Bool {
        return !exists
    }
    
    var isFile: Bool {
        return !isDirectory
    }
    
    var isDirectory: Bool {
        var isDirectory = ObjCBool(false)
        if fileManager.fileExists(atPath: internalPath, isDirectory: &isDirectory) {
            return isDirectory.boolValue
        }
        return false
    }
    
    var isDeletable: Bool {
        return fileManager.isDeletableFile(atPath: internalPath)
    }
    
    var isExecutable: Bool {
        return fileManager.isExecutableFile(atPath: internalPath)
    }
    
    var isReadable: Bool {
        return fileManager.isReadableFile(atPath: internalPath)
    }
    
    var isWritable: Bool {
        return fileManager.isWritableFile(atPath: internalPath)
    }
    
    static var currentDirectory: Path {
        return Path(fileManager.currentDirectoryPath)
    }
    
    func contentsOfDirectory(fullPaths: Bool = false) throws -> [Path] {
        let pathStrings = try fileManager.contentsOfDirectory(atPath: internalPath)
        let paths: [Path]
        if fullPaths {
            paths = pathStrings.map {
                self.appendingComponent($0)
            }
        } else {
            paths = pathStrings.map {
                Path($0)
            }
        }
        return paths
    }
    
    static var documentDirectory: Path {
        if let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last {
            return Path(documentDirectory)
        } else {
            fatalError("The Document directory could not be found.")
        }
    }
    
    static var cachesDirectory: Path {
        if let directory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last {
            return Path(directory)
        } else {
            fatalError("The Caches directory could not be found.")
        }
    }
    
    /// The application support directory typically does not exist at first.
    /// You need to create it if it doesn't exist. The getter of this variable
    /// will try to append the app bundle identifier to the path as recommended
    /// by Apple.
    static var applicationSupportDirectory: Path {
        if let directory = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).last {
            var appSupportPath = Path(directory)
            if let bundleIdentifier = Bundle.main.bundleIdentifier {
                appSupportPath = appSupportPath.appendingComponent(bundleIdentifier)
            }
            return appSupportPath
        } else {
            fatalError("The Application Support directory could not be found.")
        }
    }
    
    func becomeCurrentDirectory() {
        fileManager.changeCurrentDirectoryPath(internalPath)
    }
    
    func createDirectory(withIntermediateDirectories createIntermediateDirectories: Bool = true, attributes: [FileAttributeKey: Any]? = nil) throws {
        try fileManager.createDirectory(at: URL(fileURLWithPath: internalPath, isDirectory: true), withIntermediateDirectories: createIntermediateDirectories, attributes: attributes)
    }
    
    func remove() throws {
        try fileManager.removeItem(at: url)
    }
    
    func copy(to toPath: Path) throws {
        try fileManager.copyItem(atPath: internalPath, toPath: toPath.internalPath)
    }

    func copy(to toPath: String) throws {
        try fileManager.copyItem(atPath: internalPath, toPath: toPath)
    }
    
    func copy(to toURL: URL) throws {
        try fileManager.copyItem(at: url, to: toURL)
    }
    
    func safeReplace(withItemAt itemPath: Path) throws -> URL? {
        let resultingURL = try fileManager.replaceItemAt(url,
                                                         withItemAt: itemPath.url,
                                                         backupItemName: itemPath.url.lastPathComponent + ".safeReplaceBackup",
                                                         options: .usingNewMetadataOnly)
        return resultingURL
    }
    
    /// Set POSIX file permissions. Same as chmod. Octal number is recommended.
    func setPosixPermissions(_ permissions: Int) throws {
        try fileManager.setAttributes([.posixPermissions: permissions],
                                      ofItemAtPath: internalPath)
    }
}
