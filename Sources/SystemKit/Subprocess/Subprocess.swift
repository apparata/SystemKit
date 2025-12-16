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

/// Spawns and manages external processes with output capture support.
///
/// `Subprocess` provides a Swift-friendly interface to `posix_spawn` for launching
/// external programs, capturing their output, and waiting for completion.
///
/// ## Overview
///
/// This class manages the complete lifecycle of a subprocess:
/// 1. Create with executable path and arguments
/// 2. Spawn the process using ``spawn()``
/// 3. Wait for completion using ``wait()``
/// 4. Retrieve results including exit status and captured output
///
/// ## Usage
///
/// ```swift
/// // Simple execution
/// let subprocess = Subprocess(
///     executable: Path("/usr/bin/ls"),
///     arguments: ["-la", "/tmp"],
///     captureOutput: true
/// )
///
/// try subprocess.spawn()
/// let result = try subprocess.wait()
///
/// if result.status == 0 {
///     let output = try result.capturedOutputString()
///     print(output)
/// } else {
///     let error = try result.capturedErrorString()
///     print("Error: \(error)")
/// }
/// ```
///
/// - Note: Only available on macOS and Linux platforms
public class Subprocess {

    typealias Arguments = CStrings
    typealias Environment = KeyValueCStrings

    /// The execution state of the subprocess.
    public enum State {
        /// Initial state, not yet spawned
        case initial
        /// Currently spawning
        case spawning
        /// Successfully spawned and running
        case spawned
        /// Execution finished
        case finished
    }

    /// The process ID of the spawned subprocess.
    ///
    /// Only valid after ``spawn()`` has been called successfully.
    public private(set) var processID = pid_t()

    /// The path to the executable to run.
    public let executable: Path

    /// Command-line arguments to pass to the executable.
    public let arguments: [String]

    /// Environment variables for the subprocess.
    ///
    /// If empty, the subprocess inherits the parent's environment.
    public let environment: [String: String]

    /// Whether to capture stdout and stderr.
    public let captureOutput: Bool

    /// The result of the subprocess execution.
    ///
    /// Only available after ``wait()`` completes successfully.
    public private(set) var result: SubprocessResult? = nil

    /// The current execution state of the subprocess.
    public var state: State {
        return stateMachine.state
    }

    private let stateMachine = SubprocessStateMachine()

    private var captureOutputThread: SubprocessCaptureThread? = nil
    private var captureErrorThread: SubprocessCaptureThread? = nil

    /// Creates a new subprocess configuration.
    ///
    /// - Parameters:
    ///   - executable: The path to the executable to run
    ///   - arguments: Command-line arguments (default: empty)
    ///   - environment: Environment variables (default: empty, inherits parent)
    ///   - captureOutput: Whether to capture stdout and stderr (default: true)
    public init(executable: Path,
                arguments: [String] = [],
                environment: [String: String] = [:],
                captureOutput: Bool = true) {
        self.executable = executable
        self.arguments = arguments
        self.environment = environment
        self.captureOutput = captureOutput
    }

    /// Spawns the subprocess.
    ///
    /// This method uses `posix_spawn` to launch the executable. After spawning,
    /// use ``wait()`` to wait for completion and retrieve results.
    ///
    /// - Throws: ``SubprocessError/executableNotFound(name:)`` if the executable
    ///           doesn't exist, ``SubprocessError/alreadySpawned`` if already spawned,
    ///           or ``SubprocessError/failedToSpawn(errorCode:arguments:)`` if
    ///           spawning fails
    public func spawn() throws {
                
        guard executable.exists else {
            throw SubprocessError.executableNotFound(name: executable.string)
        }
        
        try stateMachine.enterSpawningState()
        
        let cArguments = Arguments([executable.string] + arguments)
        let cEnvironment = Environment(environment)
        let attributes = SubprocessAttributes()
        let io = try SubprocessIO(captureOutput: captureOutput)
        
        let result = posix_spawnp(&processID,
                                  cArguments.cStrings[0],
                                  &io.actions,
                                  &attributes.attributes,
                                  cArguments.cStrings,
                                  cEnvironment.cStrings)
        
        guard result == 0 else {
            throw SubprocessError.failedToSpawn(errorCode: Int(result),
                                                arguments: arguments)
        }

        if captureOutput {
            try startCapturingOutput(io: io)
        }

        stateMachine.enterSpawnedState()
    }
        
    /// Waits for the subprocess to complete and returns the result.
    ///
    /// This method blocks until the subprocess exits. It should only be called
    /// after ``spawn()`` has been called successfully.
    ///
    /// - Returns: The ``SubprocessResult`` containing exit status and captured output
    /// - Throws: ``SubprocessError/thereIsNoResult`` if the subprocess hasn't been
    ///           spawned, or ``SubprocessError/failedToWaitForExit(errorCode:)`` if
    ///           waiting fails
    @discardableResult
    public func wait() throws -> SubprocessResult {
        
        switch stateMachine.state {
        case .initial:
            throw SubprocessError.thereIsNoResult
        case .finished:
            guard let result = self.result else {
                throw SubprocessError.thereIsNoResult
            }
            return result
        default:
            break
        }
        
        let outputResult = captureOutputThread?.join()
        let errorResult = captureErrorThread?.join()
        
        let status = try waitForExit()
        
        let result = SubprocessResult(arguments: arguments,
                                  status: status,
                                  captureOutputResult: outputResult,
                                  captureErrorResult: errorResult)
        
        self.result = result
        
        stateMachine.enterFinishedState()
        
        return result
    }
    
    // MARK: - Wait for process to exit
    
    private func waitForExit() throws -> Int {
        
        var status: Int32 = 0
        var result = waitpid(processID, &status, 0)
        while result == -1 && errno == EINTR {
            result = waitpid(processID, &status, 0)
        }
        if result == -1 {
            throw SubprocessError.failedToWaitForExit(errorCode: Int(errno))
        }
        
        return Int(status)
    }
    
    // MARK: - Capture Output
    
    private func startCapturingOutput(io: SubprocessIO) throws {
        
        try io.outputPipe.closeWriteEnd()
        
        captureOutputThread = SubprocessCaptureThread(pipe: io.outputPipe)
        captureOutputThread?.start()
        
        try io.errorPipe.closeWriteEnd()
        
        captureErrorThread = SubprocessCaptureThread(pipe: io.errorPipe)
        captureErrorThread?.start()
    }
}

#endif
