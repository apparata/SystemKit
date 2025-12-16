//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation

#if os(Linux) || os(macOS)

/// Errors that can occur during subprocess operations.
///
/// These errors cover the full lifecycle of subprocess execution, from spawning
/// through output capture to waiting for completion.
///
/// - Note: Only available on macOS and Linux platforms
public enum SubprocessError: LocalizedError {

    /// Failed to spawn the subprocess.
    ///
    /// - Parameters:
    ///   - errorCode: The POSIX error code from `posix_spawn`
    ///   - arguments: The command-line arguments that were attempted
    case failedToSpawn(errorCode: Int, arguments: [String])

    /// Failed to open a pipe for output capture.
    ///
    /// - Parameter errorCode: The POSIX error code from the pipe operation
    case failedToOpenPipe(errorCode: Int)

    /// Failed to close a pipe after subprocess execution.
    ///
    /// - Parameter errorCode: The POSIX error code from the close operation
    case failedToClosePipe(errorCode: Int)

    /// Attempted to spawn a subprocess that has already been spawned.
    case alreadySpawned

    /// Failed to capture output from the subprocess.
    ///
    /// - Parameter errorCode: The error code from the capture operation
    case failedToCaptureOutput(errorCode: Int)

    /// The specified executable could not be found.
    ///
    /// - Parameter name: The name or path of the executable
    case executableNotFound(name: String)

    /// Failed while waiting for the subprocess to exit.
    ///
    /// - Parameter errorCode: The POSIX error code from `waitpid`
    case failedToWaitForExit(errorCode: Int)

    /// Captured data is not valid UTF-8 when trying to convert to string.
    case dataIsNotUTF8

    /// No result is available (subprocess has not been spawned or has not finished).
    case thereIsNoResult
    
    public var errorDescription: String? {
        switch self {
        case .failedToSpawn(let errorCode, let arguments):
            return "Error \(errorCode): Failed to launch subprocess with arguments: \(arguments)"
        case .failedToOpenPipe(let errorCode):
            return "Error \(errorCode): Failed to open pipe while launching subprocess."
        case .failedToClosePipe(let errorCode):
            return "Error \(errorCode): Failed to close pipe after running subprocess."
        case .alreadySpawned:
            return "Error: Failed to launch subprocess as it has already been launched."
        case .failedToCaptureOutput(let errorCode):
            return "Error \(errorCode): Failed to capture output from subprocess."
        case .executableNotFound(let name):
            return "Error: Cannot find the subprocess executable: \(name)"
        case .failedToWaitForExit(let errorCode):
            return "Error \(errorCode): Failed to wait for subprocess to exit."
        case .dataIsNotUTF8:
            return "Error: The requested data is not a UTF-8 compliant string."
        case .thereIsNoResult:
            return "Error: There is no subprocess result."
        }
    }
}

#endif
