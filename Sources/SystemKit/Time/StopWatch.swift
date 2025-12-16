//
//  Copyright © 2015 Apparata AB. All rights reserved.
//

import Foundation

/// A high-precision stopwatch for measuring elapsed time with pause/resume support.
///
/// `StopWatch` uses `mach_absolute_time()` for high-precision timing, making it ideal
/// for performance measurements and time-sensitive operations.
///
/// ## Overview
///
/// The stopwatch supports four states:
/// - `ready`: Initial state, not yet started
/// - `running`: Currently timing
/// - `paused`: Timing paused, can be resumed
/// - `stopped`: Timing complete
///
/// ## Usage
///
/// ```swift
/// let stopWatch = StopWatch()
/// stopWatch.start()
///
/// // ... do work ...
///
/// stopWatch.pause()
/// print("Elapsed: \(stopWatch.time) seconds")
///
/// stopWatch.resume()
/// // ... more work ...
///
/// let totalTime = stopWatch.stop()
/// print("Total: \(totalTime) seconds")
///
/// // Or create and start in one step
/// let watch = StopWatch.started()
/// ```
public final class StopWatch {

    /// The current state of the stopwatch.
    public enum StopWatchState {
        /// Ready to start (initial state)
        case ready
        /// Currently running and measuring time
        case running
        /// Paused (time accumulated but not currently running)
        case paused
        /// Stopped (final state, time measurement complete)
        case stopped
    }

    /// The current state of the stopwatch.
    public private(set) var state: StopWatchState = .ready

    /// The current elapsed time in seconds.
    ///
    /// This value is updated in real-time when the stopwatch is running.
    public var time: TimeInterval {
        switch state {
        case .ready:
            return 0.0
        case .running:
            let now = currentTime()
            return (now - beginTime) + accumulatedTime
        case .paused:
            return accumulatedTime
        case .stopped:
            return accumulatedTime
        }
    }
    
    private var accumulatedTime: TimeInterval = 0
    
    private var beginTime: TimeInterval = 0
    
    private var endTime: TimeInterval?
    
    private let timebase: mach_timebase_info? = {
        var info = mach_timebase_info()
        guard mach_timebase_info(&info) == KERN_SUCCESS else {
            print("[StopWatch] Failed to initialize timebase.")
            return nil
        }
        return info
    }()
    
    /// Creates a new stopwatch in the ready state.
    public init() { }

    deinit {
        state = .stopped
    }

    /// Creates and starts a new stopwatch in one step.
    ///
    /// - Returns: A stopwatch that is already running
    public static func started() -> StopWatch {
        let stopWatch = StopWatch()
        stopWatch.start()
        return stopWatch
    }

    /// Starts the stopwatch.
    ///
    /// - Note: Only valid when in the `ready` state. Calling from other states
    ///         will print an error message and have no effect.
    public func start() {
        guard state == .ready else {
            print("[StopWatch] Error: start() is only valid in the .Ready state.")
            return
        }
        state = .running
        beginTime = currentTime()
    }

    /// Pauses the stopwatch, preserving accumulated time.
    ///
    /// - Returns: The accumulated time at the moment of pausing
    ///
    /// - Note: Only valid when in the `running` state
    @discardableResult
    public func pause() -> TimeInterval {
        guard state == .running else {
            print("[StopWatch] Error: pause() is only valid in the .Running state.")
            return accumulatedTime
        }
        state = .paused
        accumulatedTime += (currentTime() - beginTime)
        return accumulatedTime
    }

    /// Resumes the stopwatch from a paused state.
    ///
    /// - Note: Only valid when in the `paused` state
    public func resume() {
        guard state == .paused else {
            print("[StopWatch] Error: resume() is only valid in the .Paused state.")
            return
        }
        state = .running
        beginTime = currentTime()
    }

    /// Stops the stopwatch and returns the final elapsed time.
    ///
    /// - Returns: The total accumulated time
    ///
    /// - Note: Once stopped, the stopwatch cannot be restarted
    @discardableResult
    public func stop() -> TimeInterval {
        guard state != .stopped else {
            print("[StopWatch] Error: stop() is a no-op in the .Stopped state.")
            return accumulatedTime
        }
        state = .stopped
        accumulatedTime += (currentTime() - beginTime)
        return accumulatedTime
    }
    
    private func currentTime() -> TimeInterval {
        if let timebase = timebase {
            let currentTime = mach_absolute_time()
            let nanos = currentTime * UInt64(timebase.numer) / UInt64(timebase.denom)
            return TimeInterval(nanos) / TimeInterval(NSEC_PER_SEC)
        } else {
            return ProcessInfo.processInfo.systemUptime
        }
    }
}
