//
//  Copyright © 2018 Apparata AB. All rights reserved.
//

import Foundation

/// Provides high-precision relative time measurements for performance timing.
///
/// `RelativeTime` returns time values that are only meaningful when compared to
/// each other, not to wall clock time. This makes it ideal for measuring durations
/// and performance metrics that are unaffected by system clock changes.
///
/// ## Overview
///
/// This class uses `mach_absolute_time()` for high-precision timing when available,
/// falling back to system uptime otherwise. Time values should only be used for
/// calculating elapsed time between two measurements.
///
/// ## Usage
///
/// ```swift
/// let start = RelativeTime.now
///
/// // ... perform operation ...
///
/// let end = RelativeTime.now
/// let elapsed = end - start
/// print("Operation took \(elapsed) seconds")
///
/// // Check if using high precision
/// if RelativeTime.isPrecise {
///     print("Using high-precision timing")
/// }
/// ```
///
/// - Important: Do not use these values as absolute timestamps. Only use them to
///              calculate time differences between measurements.
public final class RelativeTime {

    /// Indicates whether the high-precision timer was initialized successfully.
    ///
    /// If `true`, timing uses `mach_absolute_time()`. If `false`, falls back
    /// to `ProcessInfo.systemUptime`.
    public static let isPrecise: Bool = timebase != nil

    /// Returns the current relative time in seconds.
    ///
    /// This value represents "now" but is not wall clock time. It should only
    /// be used for calculating time differences between measurements.
    ///
    /// - Returns: The current relative time as a `TimeInterval`
    public static var now: TimeInterval {
        if let timebase = timebase {
            let currentTime = mach_absolute_time()
            let nanos = currentTime * UInt64(timebase.numer)
                        / UInt64(timebase.denom)
            return TimeInterval(nanos) / TimeInterval(NSEC_PER_SEC)
        } else {
            return ProcessInfo.processInfo.systemUptime
        }
    }
    
    private static let timebase: mach_timebase_info? = {
        var info = mach_timebase_info()
        guard mach_timebase_info(&info) == KERN_SUCCESS else {
            print("[RelativeTime] Failed to initialize timebase.")
            return nil
        }
        return info
    }()
}
