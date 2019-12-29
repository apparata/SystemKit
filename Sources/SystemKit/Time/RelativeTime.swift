//
//  Copyright © 2018 Apparata AB. All rights reserved.
//

import Foundation

/// Returns a time that represents now, but not wall clock time.
/// Only use this as a relative time, only to be compared with other
/// relative time values reported from this class.
public final class RelativeTime {
    
    /// Indicates whether high precision timer was initialized successfully.
    public static let isPrecise: Bool = timebase != nil
    
    /// Returns a time that represents now, but not wall clock time.
    /// Only use this as a relative time, only to be compared with other
    /// relative time values reported from this class.
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
