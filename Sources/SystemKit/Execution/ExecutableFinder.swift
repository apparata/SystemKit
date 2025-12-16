//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation
#if os(Linux)
import Glibc
#elseif os(macOS)
import Darwin
import Darwin.C
#endif

#if os(Linux) || os(macOS)

/// Locates executable files by name in the system PATH or current directory.
///
/// `ExecutableFinder` provides functionality similar to the Unix `which` command,
/// searching for executables in the PATH environment variable and the current directory.
///
/// ## Overview
///
/// The finder searches for executables in the following order:
/// 1. If the name contains a `/`, it's treated as a complete path
/// 2. The current working directory
/// 3. Each directory listed in the PATH environment variable
///
/// Results are cached to improve performance for repeated lookups of the same executable.
///
/// ## Usage
///
/// ```swift
/// if let gitPath = ExecutableFinder.find("git") {
///     print("Found git at: \(gitPath)")
/// }
///
/// if let pythonPath = ExecutableFinder.find("python3") {
///     print("Found python3 at: \(pythonPath)")
/// }
/// ```
///
/// - Note: This class is only available on macOS and Linux platforms.
@MainActor
public final class ExecutableFinder {

    static var cachedPaths: [String: Path?] = [:]

    /// Finds an executable by name in the system PATH or current directory.
    ///
    /// The search process:
    /// 1. If `name` contains a `/`, it's returned as-is (treated as a complete path)
    /// 2. Checks the current working directory for the executable
    /// 3. Searches each directory in the PATH environment variable
    /// 4. Returns the first match that exists and has executable permissions
    ///
    /// - Parameter name: The name of the executable to find (e.g., "git", "python3")
    /// - Returns: A `Path` to the executable if found, or `nil` if not found
    ///
    /// - Note: Results are cached for performance. The cache persists for the lifetime
    ///         of the process.
    public static func find(_ name: String) -> Path? {
        
        guard !name.contains("/") else {
            // This is already a path.
            return Path(name)
        }
        
        let fileInCurrentDirectory = Path
            .currentDirectory
            .normalized
            .appendingComponent(name)
        if fileInCurrentDirectory.exists {
            return fileInCurrentDirectory
        }
        
        if let cachedPath = cachedPaths[name] {
            return cachedPath
        }
        
        guard let pathVariable = Environment["PATH"] else {
            return nil
        }
        
        let paths = pathVariable.split(separator: ":").map {
            Path(String($0)).normalized.appendingComponent(name)
        }
        
        for path in paths {
            if path.exists && path.isExecutable {
                return path
            }
        }
                
        return nil
    }
}

#endif
