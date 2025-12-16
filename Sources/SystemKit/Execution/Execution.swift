//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

#if os(macOS)

import Foundation

/// Manages the main execution loop and signal handling for command-line applications.
///
/// `Execution` provides utilities for running macOS command-line applications with
/// proper signal handling, allowing graceful cleanup when the process receives
/// termination signals.
///
/// ## Overview
///
/// This class handles three common Unix signals:
/// - `SIGINT` (Ctrl-C): User interruption
/// - `SIGHUP`: Terminal disconnection
/// - `SIGTERM`: Termination request
///
/// ## Usage
///
/// ```swift
/// @MainActor
/// func main() {
///     // Set up your application state
///     let app = MyApplication()
///
///     // Run with signal handling
///     Execution.runUntilTerminated { signal in
///         print("Received signal: \(signal)")
///         app.cleanup()
///         return true  // Exit after cleanup
///     }
/// }
/// ```
///
/// - Note: This class is only available on macOS.
@MainActor
public final class Execution {

    /// The type of signal received by the process.
    public enum SignalType {
        /// User interrupted program, typically by pressing Ctrl-C (SIGINT).
        case interrupt

        /// Terminal disconnected, e.g., user closed terminal window (SIGHUP).
        case terminalDisconnected

        /// The program is about to be terminated (SIGTERM).
        case terminate
    }

    /// A closure that handles process termination signals.
    ///
    /// The signal handler is invoked when the process receives `SIGINT`, `SIGHUP`,
    /// or `SIGTERM`. Use this to perform cleanup operations before the process exits.
    ///
    /// - Parameter signalType: The type of signal that was received
    /// - Returns: `true` to exit the program after handling, `false` to suppress
    ///            the signal and continue running
    ///
    /// - Note: In most cases, you should return `true` to allow the process to exit
    ///         gracefully after cleanup.
    public typealias SignalHandler = (SignalType) -> Bool
    
    /// Private singleton instance.
    private static let instance = Execution()
    
    private var signalSources: [DispatchSourceSignal] = []
    private let signalQueue = DispatchQueue(label: "Execution.signalhandler")

    /// Starts the main run loop and optionally installs signal handlers.
    ///
    /// This method starts the main `RunLoop` and blocks until the process is terminated.
    /// If a signal handler is provided, it will be invoked when the process receives
    /// `SIGINT`, `SIGHUP`, or `SIGTERM` signals.
    ///
    /// - Parameter signalHandler: An optional closure to execute when a termination signal
    ///                           is received. If the handler returns `false`, the signal
    ///                           is suppressed and the program continues running.
    ///
    /// - Note: This method does not return unless a signal handler suppresses all signals.
    ///         In typical usage, this should be the last statement in your `@MainActor` main function.
    public static func runUntilTerminated(signalHandler: SignalHandler? = nil) {
        if let signalHandler = signalHandler {
            instance.signalSources = instance.installSignalHandler(signalHandler)
        }
        RunLoop.main.run()
    }
    
    /// Installs `SIGINT`, `SIGHUP`, and `SIGTERM` signal handler.
    private func installSignalHandler(_ handler: @escaping SignalHandler) -> [DispatchSourceSignal] {
        
        let sigintSource = DispatchSource.makeSignalSource(signal: SIGINT, queue: signalQueue)
        sigintSource.setEventHandler {
            let shouldExit = handler(.interrupt)
            print()
            if shouldExit {
                exit(0)
            }
        }

        let sighupSource = DispatchSource.makeSignalSource(signal: SIGHUP, queue: signalQueue)
        sigintSource.setEventHandler {
            let shouldExit = handler(.terminalDisconnected)
            print()
            if shouldExit {
                exit(0)
            }
        }
        
        let sigtermSource = DispatchSource.makeSignalSource(signal: SIGTERM, queue: signalQueue)
        sigtermSource.setEventHandler {
            let shouldExit = handler(.terminate)
            print()
            if shouldExit {
                exit(0)
            }
        }
                
        // Ignore default handlers.
        signal(SIGINT, SIG_IGN)
        signal(SIGHUP, SIG_IGN)
        signal(SIGTERM, SIG_IGN)
        
        sigintSource.resume()
        sighupSource.resume()
        sigtermSource.resume()
        
        return [sigintSource, sighupSource, sigtermSource]
    }
}

#endif
