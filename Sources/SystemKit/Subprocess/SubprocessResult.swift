//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation

#if os(Linux) || os(macOS)

/// The result of a completed subprocess execution.
///
/// `SubprocessResult` contains the exit status and optionally captured output
/// (stdout and stderr) from a subprocess that has finished execution.
///
/// ## Overview
///
/// Results are created when a subprocess completes via ``Subprocess/wait()``.
/// If output capture was enabled, you can retrieve the captured data as
/// either raw `Data` or UTF-8 decoded strings.
///
/// ## Usage
///
/// ```swift
/// let subprocess = Subprocess(executable: Path("/usr/bin/git"),
///                             arguments: ["status"],
///                             captureOutput: true)
/// try subprocess.spawn()
/// let result = try subprocess.wait()
///
/// if result.status == 0 {
///     let output = try result.capturedOutputString()
///     print(output)
/// }
/// ```
///
/// - Note: Only available on macOS and Linux platforms
public class SubprocessResult {

    /// The command-line arguments used to spawn the subprocess.
    public let arguments: [String]

    /// The exit status code of the subprocess.
    ///
    /// By convention, 0 indicates success and non-zero indicates an error.
    public let status: Int

    /// The result of capturing stdout, if output capture was enabled.
    ///
    /// Contains either the captured data or an error if capture failed.
    public let captureOutputResult: Result<Data, Error>?

    /// The result of capturing stderr, if output capture was enabled.
    ///
    /// Contains either the captured data or an error if capture failed.
    public let captureErrorResult: Result<Data, Error>?

    /// Creates a new subprocess result.
    ///
    /// - Parameters:
    ///   - arguments: The command-line arguments
    ///   - status: The exit status code
    ///   - captureOutputResult: Optional stdout capture result
    ///   - captureErrorResult: Optional stderr capture result
    public init(arguments: [String],
                status: Int,
                captureOutputResult: Result<Data, Error>?,
                captureErrorResult: Result<Data, Error>?) {
        self.arguments = arguments
        self.status = status
        self.captureOutputResult = captureOutputResult
        self.captureErrorResult = captureErrorResult
    }

    /// Returns the captured stdout data.
    ///
    /// - Returns: The raw stdout data
    /// - Throws: An error if output was not captured or capture failed
    public func capturedOutputData() throws -> Data {
        guard let result = captureOutputResult else {
            throw SubprocessError.failedToCaptureOutput(errorCode: 1337)
        }
        switch result {
        case .success(let data):
            return data
        case .failure(let error):
            throw error
        }
    }
    
    /// Returns the captured stderr data.
    ///
    /// - Returns: The raw stderr data
    /// - Throws: An error if output was not captured or capture failed
    public func capturedErrorData() throws -> Data {
        guard let result = captureErrorResult else {
            throw SubprocessError.failedToCaptureOutput(errorCode: 1337)
        }
        switch result {
        case .success(let data):
            return data
        case .failure(let error):
            throw error
        }
    }

    /// Returns the captured stdout as a UTF-8 string.
    ///
    /// - Returns: The stdout output as a string
    /// - Throws: `SubprocessError.dataIsNotUTF8` if the data is not valid UTF-8,
    ///           or an error if output was not captured or capture failed
    public func capturedOutputString() throws -> String {
        let data = try capturedOutputData()
        guard let string = String(data: data, encoding: .utf8) else {
            throw SubprocessError.dataIsNotUTF8
        }
        return string
    }

    /// Returns the captured stderr as a UTF-8 string.
    ///
    /// - Returns: The stderr output as a string
    /// - Throws: `SubprocessError.dataIsNotUTF8` if the data is not valid UTF-8,
    ///           or an error if output was not captured or capture failed
    public func capturedErrorString() throws -> String {
        let data = try capturedErrorData()
        guard let string = String(data: data, encoding: .utf8) else {
            throw SubprocessError.dataIsNotUTF8
        }
        return string
    }
}

#endif
