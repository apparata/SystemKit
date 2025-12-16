//
//  Copyright © 2019 Apparata AB. All rights reserved.
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
public struct Path: Sendable, Codable {

    fileprivate let path: String

    var internalPath: String {
        path
    }

    /// Indicates whether the path is absolute.
    ///
    /// An absolute path starts with a forward slash (`/`) and specifies a location
    /// from the file system root.
    ///
    /// - Returns: `true` if the path is absolute, `false` otherwise
    public var isAbsolute: Bool {
        path.first == "/"
    }

    /// Indicates whether the path is relative.
    ///
    /// A relative path does not start with a forward slash and is interpreted
    /// relative to the current working directory.
    ///
    /// - Returns: `true` if the path is relative, `false` otherwise
    public var isRelative: Bool {
        !isAbsolute
    }

    /// Returns a normalized version of the path.
    ///
    /// Normalization performs the following operations:
    /// - Resolves `.` and `..` components
    /// - Removes redundant slashes
    /// - Expands `~` to the user's home directory
    /// - Removes trailing slashes
    ///
    /// - Returns: A new `Path` with the normalized path
    public var normalized: Path {
        Path((path as NSString).standardizingPath)
    }

    /// The path as a string.
    ///
    /// - Returns: The string representation of the path
    public var string: String {
        path
    }

    /// The path as a file URL.
    ///
    /// - Returns: A file `URL` representation of the path
    public var url: URL {
        URL(fileURLWithPath: path)
    }
    
    /// Creates a path representing the current directory (`.`).
    public init() {
        path = "."
    }

    /// Creates a path from a string.
    ///
    /// - Parameter path: The string path. If empty, the path will be set to `.` (current directory)
    public init(_ path: String) {
        if path.isEmpty {
            self.path = "."
        } else {
            self.path = path
        }
    }

    /// Creates a path from a file URL.
    ///
    /// - Parameter fileURL: The file URL to convert to a path
    ///
    /// - Precondition: The URL must be a file URL (not a web URL)
    public init(_ fileURL: URL) {
        precondition(fileURL.isFileURL)
        if #available(iOS 16, macOS 13.0, tvOS 16, *) {
            path = fileURL.path(percentEncoded: false)
        } else {
            path = fileURL.path
        }
    }

    /// Appends another path to this path.
    ///
    /// - Parameter path: The path to append
    /// - Returns: A new `Path` with the appended component
    public func appending(_ path: Path) -> Path {
        Path((self.path as NSString).appendingPathComponent(path.path))
    }
    
    /// Creates a path from a collection of path components.
    ///
    /// - Parameter components: A collection of path component strings
    public init<T: Collection>(components: T) where T.Iterator.Element == String {
        if components.isEmpty {
            path = "."
        } else {
            let strings: [String] = components.map { $0 }
            path = NSString.path(withComponents: strings)
        }
    }

    /// The last component of the path.
    ///
    /// For example, the last component of `/usr/bin/swift` is `swift`.
    ///
    /// - Returns: The last path component as a string
    public var lastComponent: String {
        (path as NSString).lastPathComponent
    }

    /// Returns a new path with the last component removed.
    ///
    /// For example, deleting the last component of `/usr/bin/swift` yields `/usr/bin`.
    ///
    /// - Returns: A new `Path` without the last component
    public var deletingLastComponent: Path {
        Path((path as NSString).deletingLastPathComponent)
    }

    /// Returns a new path by appending a component.
    ///
    /// - Parameter string: The component to append
    /// - Returns: A new `Path` with the appended component
    public func appendingComponent(_ string: String) -> Path {
        Path((path as NSString).appendingPathComponent(string))
    }

    /// Returns a new path with the last component replaced.
    ///
    /// - Parameter string: The new last component
    /// - Returns: A new `Path` with the replaced component
    public func replacingLastComponent(with string: String) -> Path {
        deletingLastComponent.appendingComponent(string)
    }

    /// The file extension of the path.
    ///
    /// For example, the extension of `photo.jpg` is `jpg`.
    ///
    /// - Returns: The file extension without the leading dot, or an empty string if none
    public var `extension`: String {
        (path as NSString).pathExtension
    }

    /// Returns a new path with the file extension removed.
    ///
    /// For example, deleting the extension of `photo.jpg` yields `photo`.
    ///
    /// - Returns: A new `Path` without the file extension
    public var deletingExtension: Path {
        Path((path as NSString).deletingPathExtension)
    }

    /// Returns a new path by appending a file extension.
    ///
    /// - Parameter string: The extension to append (without the leading dot)
    /// - Returns: A new `Path` with the appended extension
    public func appendingExtension(_ string: String) -> Path {
        guard let newPath = (path as NSString).appendingPathExtension(string) else {
            // Not sure what could cause it to be nil, so here's a fallback plan.
            return Path(path + "." + string)
        }
        return Path(newPath)
    }

    /// Returns a new path with the file extension replaced.
    ///
    /// - Parameter string: The new extension (without the leading dot)
    /// - Returns: A new `Path` with the replaced extension
    public func replacingExtension(with string: String) -> Path {
        deletingExtension.appendingExtension(string)
    }
}

// MARK: - Object Description

extension Path: CustomStringConvertible {
    public var description: String {
        path
    }
}

// MARK: - String Literal Convertible

extension Path: ExpressibleByStringLiteral {
    public typealias UnicodeScalarLiteralType = StringLiteralType
    public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
    
    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        let valueString = "\(value)"
        if valueString.isEmpty {
            path = "."
        } else {
            path = valueString
        }
    }
    
    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        let valueString: String = value
        if valueString.isEmpty {
            path = "."
        } else {
            path = valueString
        }
    }
    
    public init(stringLiteral value: StringLiteralType) {
        let valueString: String = value
        if valueString.isEmpty {
            path = "."
        } else {
            path = valueString
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
        lhs.path == rhs.path
    }
}

extension Path : Comparable {
 
    public static func <(lhs: Path, rhs: Path) -> Bool {
        lhs.path < rhs.path
    }
}

// MARK: - Concatenation

/// Concatenates two paths by appending the right path to the left path.
///
/// - Parameters:
///   - lhs: The base path
///   - rhs: The path to append
/// - Returns: A new `Path` representing the concatenated paths
public func +(lhs: Path, rhs: Path) -> Path {
    lhs.appending(rhs)
}

/// Appends a string component to a path.
///
/// - Parameters:
///   - lhs: The base path
///   - rhs: The component to append
/// - Returns: A new `Path` with the appended component
public func +(lhs: Path, rhs: String) -> Path {
    lhs.appendingComponent(rhs)
}

// MARK: - File Management

public extension Path {
    
    fileprivate static var fileManager: FileManager {
        FileManager.default
    }
    
    fileprivate var fileManager: FileManager {
        FileManager.default
    }
    
    /// Marks the file or directory to be excluded from iCloud and iTunes backups.
    ///
    /// This is useful for cache files, temporary data, and other files that can be
    /// regenerated and should not be backed up.
    ///
    /// - Throws: An error if setting the resource value fails
    ///
    /// - Note: This is a no-op if the file does not exist
    func excludeFromBackup() throws {
        guard exists else {
            return
        }

        let mutableURL: NSURL = url as NSURL

        try mutableURL.setResourceValue(true, forKey: URLResourceKey.isExcludedFromBackupKey)
    }

    /// Indicates whether a file or directory exists at this path.
    ///
    /// - Returns: `true` if the file or directory exists, `false` otherwise
    var exists: Bool {
        fileManager.fileExists(atPath: internalPath)
    }

    /// Indicates whether no file or directory exists at this path.
    ///
    /// - Returns: `true` if nothing exists at the path, `false` otherwise
    var doesNotExist: Bool {
        !exists
    }

    /// Indicates whether the path represents a file (not a directory).
    ///
    /// - Returns: `true` if the path is a file, `false` if it's a directory or doesn't exist
    var isFile: Bool {
        !isDirectory
    }

    /// Indicates whether the path represents a directory.
    ///
    /// - Returns: `true` if the path is a directory, `false` otherwise
    var isDirectory: Bool {
        var isDirectory = ObjCBool(false)
        if fileManager.fileExists(atPath: internalPath, isDirectory: &isDirectory) {
            return isDirectory.boolValue
        }
        return false
    }

    /// Indicates whether the file or directory can be deleted.
    ///
    /// - Returns: `true` if deletable, `false` otherwise
    var isDeletable: Bool {
        fileManager.isDeletableFile(atPath: internalPath)
    }

    /// Indicates whether the file is executable.
    ///
    /// - Returns: `true` if executable, `false` otherwise
    var isExecutable: Bool {
        fileManager.isExecutableFile(atPath: internalPath)
    }

    /// Indicates whether the file or directory is readable.
    ///
    /// - Returns: `true` if readable, `false` otherwise
    var isReadable: Bool {
        fileManager.isReadableFile(atPath: internalPath)
    }

    /// Indicates whether the file or directory is writable.
    ///
    /// - Returns: `true` if writable, `false` otherwise
    var isWritable: Bool {
        fileManager.isWritableFile(atPath: internalPath)
    }
    
    /// Returns the contents of the directory at this path.
    ///
    /// - Parameter fullPaths: If `true`, returns full paths; if `false`, returns relative names
    /// - Returns: An array of paths representing the directory contents
    /// - Throws: An error if the directory cannot be read
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

    /// Returns all contents of the directory recursively, including subdirectories.
    ///
    /// - Parameter fullPaths: If `true`, returns full paths; if `false`, returns relative paths
    /// - Returns: An array of paths representing all contents recursively
    /// - Throws: An error if the directory cannot be read
    func recursiveContentsOfDirectory(fullPaths: Bool = false) throws -> [Path] {
        let pathStrings = try fileManager.subpathsOfDirectory(atPath: internalPath)
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
    
    /// The current working directory.
    @available(iOS 16, macOS 13.0, tvOS 16, *)
    static var current: Path {
        Path(fileManager.currentDirectoryPath)
    }

    /// The current working directory.
    ///
    /// - Note: Deprecated in favor of ``current``
    @available(iOS, deprecated: 16.0)
    @available(macOS, deprecated: 13.0)
    @available(tvOS, deprecated: 16.0)
    static var currentDirectory: Path {
        Path(fileManager.currentDirectoryPath)
    }

    /// The current user's home directory.
    @available(iOS 16, macOS 13.0, tvOS 16, *)
    static var home: Path {
        return Self(.homeDirectory)
    }

    /// The current user's home directory.
    ///
    /// - Note: Deprecated in favor of ``home``
    @available(iOS, deprecated: 16.0)
    @available(macOS, deprecated: 13.0)
    @available(tvOS, deprecated: 16.0)
    static var homeDirectory: Path {
        Path(NSHomeDirectory())
    }

    /// The system's temporary directory.
    static var temporaryDirectory: Path {
        Path(NSTemporaryDirectory())
    }

    /// The current user's documents directory.
    @available(iOS 16, macOS 13.0, tvOS 16, *)
    static var documents: Path {
        return Self(.documentsDirectory)
    }

    /// The current user's documents directory.
    ///
    /// - Note: Deprecated in favor of ``documents``
    @available(iOS, deprecated: 16.0)
    @available(macOS, deprecated: 13.0)
    @available(tvOS, deprecated: 16.0)
    static var documentDirectory: Path? {
        if #available(iOS 16, macOS 13, tvOS 16, *) {
            return Path(URL.documentsDirectory.path(percentEncoded: false))
        } else {
            if let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last {
                return Path(documentDirectory)
            } else {
                return nil
            }
        }
    }
    
    /// The current user's caches directory.
    @available(iOS 16, macOS 13.0, tvOS 16, *)
    static var caches: Path {
        return Self(.cachesDirectory)
    }

    /// The current user's caches directory.
    ///
    /// - Note: Deprecated in favor of ``caches``
    @available(iOS, deprecated: 16.0)
    @available(macOS, deprecated: 13.0)
    @available(tvOS, deprecated: 16.0)
    static var cachesDirectory: Path? {
        if #available(iOS 16, macOS 13, tvOS 16, *) {
            return Path(URL.cachesDirectory.path(percentEncoded: false))
        } else {
            if let directory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last {
                return Path(directory)
            } else {
                return nil
            }
        }
    }

    /// The application support directory for the current app.
    ///
    /// The path includes the app's bundle identifier as recommended by Apple.
    ///
    /// - Returns: The application support directory path, or `nil` if unavailable
    ///
    /// - Note: This directory typically does not exist initially and must be created
    ///         before use
    static var applicationSupportDirectory: Path? {
        if let directory = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).last {
            var appSupportPath = Path(directory)
            if let bundleIdentifier = Bundle.main.bundleIdentifier {
                appSupportPath = appSupportPath.appendingComponent(bundleIdentifier)
            }
            return appSupportPath
        } else {
            return nil
        }
    }
    
    /// The current user's downloads directory.
    ///
    /// - Returns: The downloads directory path, or `nil` if unavailable
    static var downloadsDirectory: Path? {
        if let documentDirectory = NSSearchPathForDirectoriesInDomains(.downloadsDirectory, .userDomainMask, true).last {
            return Path(documentDirectory)
        } else {
            return nil
        }
    }

    /// The current user's desktop directory.
    ///
    /// - Returns: The desktop directory path, or `nil` if unavailable
    static var desktopDirectory: Path? {
        if let documentDirectory = NSSearchPathForDirectoriesInDomains(.desktopDirectory, .userDomainMask, true).last {
            return Path(documentDirectory)
        } else {
            return nil
        }
    }

    /// The system's applications directory.
    ///
    /// - Returns: The applications directory path, or `nil` if unavailable
    static var applicationsDirectory: Path? {
        if let documentDirectory = NSSearchPathForDirectoriesInDomains(.applicationDirectory, .userDomainMask, true).last {
            return Path(documentDirectory)
        } else {
            return nil
        }
    }

    /// Changes the current working directory to this path.
    func becomeCurrentDirectory() {
        fileManager.changeCurrentDirectoryPath(internalPath)
    }

    /// Creates a directory at this path.
    ///
    /// - Parameters:
    ///   - createIntermediateDirectories: If `true`, creates intermediate directories as needed
    ///   - attributes: File attributes to apply to the directory
    /// - Throws: An error if the directory cannot be created
    func createDirectory(withIntermediateDirectories createIntermediateDirectories: Bool = true, attributes: [FileAttributeKey: Any]? = nil) throws {
        try fileManager.createDirectory(at: URL(fileURLWithPath: internalPath, isDirectory: true), withIntermediateDirectories: createIntermediateDirectories, attributes: attributes)
    }

    /// Removes the file or directory at this path.
    ///
    /// - Throws: An error if the item cannot be removed
    func remove() throws {
        try fileManager.removeItem(at: url)
    }

    /// Copies the file or directory at this path to another path.
    ///
    /// - Parameter toPath: The destination path
    /// - Throws: An error if the copy operation fails
    func copy(to toPath: Path) throws {
        try fileManager.copyItem(atPath: internalPath, toPath: toPath.internalPath)
    }

    /// Copies the file or directory at this path to another path.
    ///
    /// - Parameter toPath: The destination path as a string
    /// - Throws: An error if the copy operation fails
    func copy(to toPath: String) throws {
        try fileManager.copyItem(atPath: internalPath, toPath: toPath)
    }

    /// Copies the file or directory at this path to a URL.
    ///
    /// - Parameter toURL: The destination URL
    /// - Throws: An error if the copy operation fails
    func copy(to toURL: URL) throws {
        try fileManager.copyItem(at: url, to: toURL)
    }

    /// Moves the file or directory at this path to another path.
    ///
    /// - Parameter toPath: The destination path
    /// - Throws: An error if the move operation fails
    func move(to toPath: Path) throws {
        try fileManager.moveItem(atPath: internalPath, toPath: toPath.internalPath)
    }

    /// Moves the file or directory at this path to another path.
    ///
    /// - Parameter toPath: The destination path as a string
    /// - Throws: An error if the move operation fails
    func move(to toPath: String) throws {
        try fileManager.moveItem(atPath: internalPath, toPath: toPath)
    }

    /// Moves the file or directory at this path to a URL.
    ///
    /// - Parameter toURL: The destination URL
    /// - Throws: An error if the move operation fails
    func move(to toURL: URL) throws {
        try fileManager.moveItem(at: url, to: toURL)
    }

    /// Safely replaces the item at this path with another item, creating a backup.
    ///
    /// - Parameter itemPath: The path to the replacement item
    /// - Returns: The URL of the resulting item, or `nil` if no URL is available
    /// - Throws: An error if the replacement operation fails
    func safeReplace(withItemAt itemPath: Path) throws -> URL? {
        let resultingURL = try fileManager.replaceItemAt(url,
                                                         withItemAt: itemPath.url,
                                                         backupItemName: itemPath.url.lastPathComponent + ".safeReplaceBackup",
                                                         options: .usingNewMetadataOnly)
        return resultingURL
    }

    /// Sets POSIX file permissions on the file or directory.
    ///
    /// This method is equivalent to the Unix `chmod` command.
    ///
    /// - Parameter permissions: The permissions to set (octal notation is recommended)
    /// - Throws: An error if the permissions cannot be set
    func setPosixPermissions(_ permissions: PosixPermissions) throws {
        try fileManager.setAttributes([.posixPermissions: permissions.rawValue],
                                      ofItemAtPath: internalPath)
    }
}

/// POSIX file permission flags compatible with Unix `chmod` command.
///
/// Use this type to specify file and directory permissions using familiar Unix
/// permission bits. Permissions can be combined using set operations.
///
/// ## Usage
///
/// ```swift
/// // Using octal notation (recommended)
/// try path.setPosixPermissions(0o755)
///
/// // Using named constants
/// let permissions: PosixPermissions = [.readableByOwner, .writableByOwner, .executableByOwner,
///                                       .readableByGroup, .executableByGroup,
///                                       .readableByOthers, .executableByOthers]
/// try path.setPosixPermissions(permissions)
/// ```
public struct PosixPermissions: Sendable, OptionSet, ExpressibleByIntegerLiteral {

    public let rawValue: Int

    /// Creates permissions from a raw integer value.
    ///
    /// - Parameter rawValue: The raw permission bits
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// Creates permissions from an integer literal.
    ///
    /// This allows using octal notation: `let perms: PosixPermissions = 0o755`
    ///
    /// - Parameter value: The permission value (octal notation recommended)
    public init(integerLiteral value: Int) {
        self.init(rawValue: value)
    }
    
    /// Executable files with the `setuid` bit set will run with effective uid set to the uid of the file owner.
    /// Directories with this bit set will force all files and sub-directories created in them to be owned by the
    /// directory owner and not by the uid of the creating process, if the underlying file system supports this
    /// feature: see chmod(2) and the suiddir option to mount(8).
    public static let setuid: Self = 0o4000
    
    /// Executable files with the `setgid` bit set will run with effective gid set to the gid of the file owner.
    public static let setgid: Self = 0o2000
    
    /// When a directory's `sticky` bit is set, the filesystem treats the files in such directories in a
    /// special way so only the file's owner, the directory's owner, or root user can rename or delete the file.
    /// See chmod(2) and sticky(7).
    public static let sticky: Self = 0o1000
    
    /// Allow read by owner.
    public static let readableByOwner: Self = 0o0400
    
    /// Allow write by owner.
    public static let writableByOwner: Self = 0o0200
    
    /// For files, allow execution by owner.  For directories, allow the owner to search in the directory.
    public static let executableByOwner: Self = 0o0100

    /// Allow read by group members.
    public static let readableByGroup: Self = 0o0040

    /// Allow write by group members.
    public static let writableByGroup: Self = 0o0020

    /// For files, allow execution by group.  For directories, allow group members to search in the directory.
    public static let executableByGroup: Self = 0o0010

    /// Allow read by others.
    public static let readableByOthers: Self = 0o0004

    /// Allow write by others.
    public static let writableByOthers: Self = 0o0002

    /// For files, allow execution by others.  For directories allow others to search in the directory.
    public static let executableByOthers: Self = 0o0001
}
