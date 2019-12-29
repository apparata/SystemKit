//
//  Copyright © 2016 Apparata AB. All rights reserved.
//

import Foundation

public class Timer {
    
    public typealias TimerHandler = (_ timer: Timer) -> Void
    
    public var handler: TimerHandler?
    
    private var timer: Foundation.Timer?
    
    public init() {
    }
    
    deinit {
        timer?.invalidate()
    }
    
    public func startOneShot(_ timeInterval: Foundation.TimeInterval) {
        start(timeInterval, repeats: false)
    }
    
    public func startRepeating(_ timeInterval: Foundation.TimeInterval) {
        start(timeInterval, repeats: true)
    }
    
    private func start(_ timeInterval: Foundation.TimeInterval, repeats: Bool) {
        if let oldTimer = timer {
            oldTimer.invalidate()
        }
        
        timer = Foundation.Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(Timer.timerFiredHandler(_:)), userInfo: nil, repeats: repeats)
    }
    
    public func stop() {
        timer?.invalidate()
    }
    
    @objc private func timerFiredHandler(_ timer: Any) {
        handler?(self)
    }
}
