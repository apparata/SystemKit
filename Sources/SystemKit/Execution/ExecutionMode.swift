//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation

public final class ExecutionMode {
    
    /// Indicates whether a debugger is currently attached or not.
    public static let isDebuggerAttached: Bool = {
        var info = kinfo_proc()
        var mib : [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        var size = MemoryLayout<kinfo_proc>.stride
        let junk = sysctl(&mib, UInt32(mib.count), &info, &size, nil, 0)
        assert(junk == 0, "sysctl failed")
        return (info.kp_proc.p_flag & P_TRACED) != 0
    }()
    
    /// Indicates whether the code is running under test.
    public static let isRunningUnitTests: Bool = {
        #if DEBUG
        return NSClassFromString("XCTest") != nil
        #else
        return false
        #endif
    }()
}
