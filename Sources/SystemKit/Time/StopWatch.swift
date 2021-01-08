//
//  Copyright © 2015 Apparata AB. All rights reserved.
//

import Foundation

public final class StopWatch {
    
    public enum StopWatchState {
        case ready
        case running
        case paused
        case stopped
    }
    
    public private(set) var state: StopWatchState = .ready
    
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
    
    public init() { }
    
    deinit {
        state = .stopped
    }
    
    public static func started() -> StopWatch {
        let stopWatch = StopWatch()
        stopWatch.start()
        return stopWatch
    }
    
    public func start() {
        guard state == .ready else {
            print("[StopWatch] Error: start() is only valid in the .Ready state.")
            return
        }
        state = .running
        beginTime = currentTime()
    }
        
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
    
    public func resume() {
        guard state == .paused else {
            print("[StopWatch] Error: resume() is only valid in the .Paused state.")
            return
        }
        state = .running
        beginTime = currentTime()
    }
    
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
