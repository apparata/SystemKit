//
//  Copyright © 2016 Apparata AB. All rights reserved.
//

import Foundation

/// A simple wrapper around Foundation.Timer with closure-based callbacks.
///
/// `Timer` provides a straightforward interface for scheduling one-shot or repeating
/// timer events using closures instead of selectors.
///
/// ## Overview
///
/// This timer automatically manages the underlying `Foundation.Timer` lifecycle,
/// invalidating it when the `Timer` object is deallocated or when `stop()` is called.
///
/// ## Usage
///
/// ```swift
/// let timer = Timer()
/// timer.handler = { timer in
///     print("Timer fired!")
/// }
///
/// // One-shot timer
/// timer.startOneShot(2.0)  // Fires after 2 seconds
///
/// // Repeating timer
/// timer.startRepeating(1.0)  // Fires every second
///
/// // Stop the timer
/// timer.stop()
/// ```
///
/// - Note: The timer is automatically invalidated when deallocated
public class Timer {

    /// A closure called when the timer fires.
    ///
    /// - Parameter timer: The `Timer` instance that fired
    public typealias TimerHandler = (_ timer: Timer) -> Void

    /// The handler closure to call when the timer fires.
    public var handler: TimerHandler?

    private var timer: Foundation.Timer?

    /// Creates a new timer.
    ///
    /// Set the ``handler`` property and call ``startOneShot(_:)`` or
    /// ``startRepeating(_:)`` to begin timing.
    public init() {
    }

    deinit {
        timer?.invalidate()
    }

    /// Starts a one-shot timer that fires once after the specified interval.
    ///
    /// If a timer is already running, it will be stopped and replaced.
    ///
    /// - Parameter timeInterval: The number of seconds to wait before firing
    public func startOneShot(_ timeInterval: Foundation.TimeInterval) {
        start(timeInterval, repeats: false)
    }

    /// Starts a repeating timer that fires repeatedly at the specified interval.
    ///
    /// If a timer is already running, it will be stopped and replaced.
    ///
    /// - Parameter timeInterval: The number of seconds between firings
    public func startRepeating(_ timeInterval: Foundation.TimeInterval) {
        start(timeInterval, repeats: true)
    }

    private func start(_ timeInterval: Foundation.TimeInterval, repeats: Bool) {
        if let oldTimer = timer {
            oldTimer.invalidate()
        }

        timer = Foundation.Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(Timer.timerFiredHandler(_:)), userInfo: nil, repeats: repeats)
    }

    /// Stops the timer if it's currently running.
    public func stop() {
        timer?.invalidate()
    }
    
    @objc private func timerFiredHandler(_ timer: Any) {
        handler?(self)
    }
}
