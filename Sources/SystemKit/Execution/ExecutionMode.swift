//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation

/// Detects the execution context of the current process.
///
/// `ExecutionMode` provides utilities to determine whether the process is running
/// under specific conditions such as debugging or unit testing. This is useful for
/// conditional behavior during development and testing.
///
/// ## Overview
///
/// The class provides compile-time and runtime detection of:
/// - Debugger attachment (via process flags)
/// - XCTest framework presence (indicating unit tests are running)
///
/// ## Usage
///
/// ```swift
/// if ExecutionMode.isDebuggerAttached {
///     print("Running under debugger")
/// }
///
/// if ExecutionMode.isRunningUnitTests {
///     // Skip certain initialization in tests
///     return
/// }
/// ```
///
/// - Note: Detection is performed once at application launch and cached.
public final class ExecutionMode {

    /// Indicates whether a debugger is currently attached to the process.
    ///
    /// This property checks the `P_TRACED` flag in the process's `kinfo_proc` structure
    /// to determine if a debugger (such as LLDB or Xcode) is attached.
    ///
    /// - Returns: `true` if a debugger is attached, `false` otherwise
    ///
    /// - Note: The value is computed once at initialization and cached for performance.
    public static let isDebuggerAttached: Bool = {
        var info = kinfo_proc()
        var mib : [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        var size = MemoryLayout<kinfo_proc>.stride
        let junk = sysctl(&mib, UInt32(mib.count), &info, &size, nil, 0)
        assert(junk == 0, "sysctl failed")
        return (info.kp_proc.p_flag & P_TRACED) != 0
    }()

    /// Indicates whether the code is running as part of a unit test.
    ///
    /// This property detects the presence of the XCTest framework by checking if
    /// the `XCTest` class can be found in the runtime.
    ///
    /// - Returns: `true` if XCTest is present (indicating unit tests are running),
    ///            `false` otherwise
    ///
    /// - Note: This check only works in DEBUG builds. In release builds, this
    ///         property always returns `false`.
    public static let isRunningUnitTests: Bool = {
        #if DEBUG
        return NSClassFromString("XCTest") != nil
        #else
        return false
        #endif
    }()
}
