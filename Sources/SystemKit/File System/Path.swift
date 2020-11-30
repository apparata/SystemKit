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
public struct Path: Codable {
    
    fileprivate var path: String
    
    var internalPath: String {
        path
    }
        
    public var isAbsolute: Bool {
        path.first == "/"
    }
    
    public var isRelative: Bool {
        !isAbsolute
    }
    
    public var normalized: Path {
        Path((path as NSString).standardizingPath)
    }
    
    public var string: String {
        path
    }
    
    public var url: URL {
        URL(fileURLWithPath: path)
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
        Path((self.path as NSString).appendingPathComponent(path.path))
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
        (path as NSString).lastPathComponent
    }
    
    public var deletingLastComponent: Path {
        Path((path as NSString).deletingLastPathComponent)
    }
    
    public func appendingComponent(_ string: String) -> Path {
        Path((path as NSString).appendingPathComponent(string))
    }
    
    public func replacingLastComponent(with string: String) -> Path {
        deletingLastComponent.appendingComponent(string)
    }
    
    public var `extension`: String {
        (path as NSString).pathExtension
    }
    
    public var deletingExtension: Path {
        Path((path as NSString).deletingPathExtension)
    }
    
    public func appendingExtension(_ string: String) -> Path {
        guard let newPath = (path as NSString).appendingPathExtension(string) else {
            // Not sure what could cause it to be nil, so here's a fallback plan.
            return Path(path + "." + string)
        }
        return Path(newPath)
    }
    
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
        lhs.path == rhs.path
    }
}

extension Path : Comparable {
 
    public static func <(lhs: Path, rhs: Path) -> Bool {
        lhs.path < rhs.path
    }
}

// MARK: - Concatenation

public func +(lhs: Path, rhs: Path) -> Path {
    lhs.appending(rhs)
}

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
    
    /// Note: No-op if file does not exist.
    func excludeFromBackup() throws {
        guard exists else {
            return
        }
        
        let mutableURL: NSURL = url as NSURL
        
        try mutableURL.setResourceValue(true, forKey: URLResourceKey.isExcludedFromBackupKey)
    }
    
    var exists: Bool {
        fileManager.fileExists(atPath: internalPath)
    }
    
    var doesNotExist: Bool {
        !exists
    }
    
    var isFile: Bool {
        !isDirectory
    }
    
    var isDirectory: Bool {
        var isDirectory = ObjCBool(false)
        if fileManager.fileExists(atPath: internalPath, isDirectory: &isDirectory) {
            return isDirectory.boolValue
        }
        return false
    }
    
    var isDeletable: Bool {
        fileManager.isDeletableFile(atPath: internalPath)
    }
    
    var isExecutable: Bool {
        fileManager.isExecutableFile(atPath: internalPath)
    }
    
    var isReadable: Bool {
        fileManager.isReadableFile(atPath: internalPath)
    }
    
    var isWritable: Bool {
        fileManager.isWritableFile(atPath: internalPath)
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

    static var currentDirectory: Path {
        Path(fileManager.currentDirectoryPath)
    }
    
    static var homeDirectory: Path {
        Path(NSHomeDirectory())
    }
    
    static var temporaryDirectory: Path {
        Path(NSTemporaryDirectory())
    }
            
    static var documentDirectory: Path? {
        if let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last {
            return Path(documentDirectory)
        } else {
            return nil
        }
    }
    
    static var cachesDirectory: Path? {
        if let directory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last {
            return Path(directory)
        } else {
            return nil
        }
    }
    
    /// The application support directory typically does not exist at first.
    /// You need to create it if it doesn't exist. The getter of this variable
    /// will try to append the app bundle identifier to the path as recommended
    /// by Apple.
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
    
    static var downloadsDirectory: Path? {
        if let documentDirectory = NSSearchPathForDirectoriesInDomains(.downloadsDirectory, .userDomainMask, true).last {
            return Path(documentDirectory)
        } else {
            return nil
        }
    }
    
    static var desktopDirectory: Path? {
        if let documentDirectory = NSSearchPathForDirectoriesInDomains(.desktopDirectory, .userDomainMask, true).last {
            return Path(documentDirectory)
        } else {
            return nil
        }
    }
    
    static var applicationsDirectory: Path? {
        if let documentDirectory = NSSearchPathForDirectoriesInDomains(.applicationDirectory, .userDomainMask, true).last {
            return Path(documentDirectory)
        } else {
            return nil
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
    
    func move(to toPath: Path) throws {
        try fileManager.moveItem(atPath: internalPath, toPath: toPath.internalPath)
    }

    func move(to toPath: String) throws {
        try fileManager.moveItem(atPath: internalPath, toPath: toPath)
    }

    func move(to toURL: URL) throws {
        try fileManager.moveItem(at: url, to: toURL)
    }

    func safeReplace(withItemAt itemPath: Path) throws -> URL? {
        let resultingURL = try fileManager.replaceItemAt(url,
                                                         withItemAt: itemPath.url,
                                                         backupItemName: itemPath.url.lastPathComponent + ".safeReplaceBackup",
                                                         options: .usingNewMetadataOnly)
        return resultingURL
    }
    
    /// Set POSIX file permissions. Same as chmod. Octal number is recommended.
    func setPosixPermissions(_ permissions: PosixPermissions) throws {
        try fileManager.setAttributes([.posixPermissions: permissions.rawValue],
                                      ofItemAtPath: internalPath)
    }
}

public struct PosixPermissions: OptionSet, ExpressibleByIntegerLiteral {

    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
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
