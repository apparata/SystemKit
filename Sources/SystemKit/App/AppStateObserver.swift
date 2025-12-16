//
//  Copyright © 2015 Apparata AB. All rights reserved.
//

#if canImport(UIKit)
import UIKit

/// A convenience observer that monitors iOS application lifecycle state changes.
///
/// `AppStateObserver` provides a simplified interface for observing UIApplication state
/// transitions by wrapping `NotificationCenter` observations with closure-based handlers.
///
/// ## Overview
///
/// Use this class to respond to application lifecycle events without manually managing
/// notification observers. Simply assign closures to the properties corresponding to
/// the lifecycle events you want to observe.
///
/// ## Usage
///
/// ```swift
/// let observer = AppStateObserver()
/// observer.appDidBecomeActive = {
///     print("App became active")
/// }
/// observer.appWillResignActive = {
///     print("App will resign active")
/// }
/// ```
///
/// The observer automatically registers for notifications on initialization and
/// unregisters on deallocation.
///
/// - Note: This class is only available on iOS platforms where UIKit is available.
public final class AppStateObserver {

    /// A closure called when the app is about to become inactive.
    ///
    /// This corresponds to `UIApplication.willResignActiveNotification` and is typically
    /// triggered when the user receives a phone call or SMS, or when transitioning to
    /// another app.
    public var appWillResignActive: (() -> ())?

    /// A closure called when the app has entered the background.
    ///
    /// This corresponds to `UIApplication.didEnterBackgroundNotification` and is called
    /// when the app is no longer visible on screen. Use this to save user data and
    /// release shared resources.
    public var appDidEnterBackground: (() -> ())?

    /// A closure called when the app is about to enter the foreground.
    ///
    /// This corresponds to `UIApplication.willEnterForegroundNotification` and is called
    /// as the app transitions from the background to the active state.
    public var appWillEnterForeground: (() -> ())?

    /// A closure called when the app has become active.
    ///
    /// This corresponds to `UIApplication.didBecomeActiveNotification` and is called
    /// when the app has transitioned to the active state and is ready to receive events.
    public var appDidBecomeActive: (() -> ())?

    /// Creates a new application state observer.
    ///
    /// The initializer automatically registers for all UIApplication state change
    /// notifications. Set the corresponding closure properties to respond to events.
    public init() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(AppStateObserver.appWillResignActive(notification:)),
            name: UIApplication.willResignActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(AppStateObserver.appDidEnterBackground(notification:)),
            name: UIApplication.didEnterBackgroundNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(AppStateObserver.appWillEnterForeground(notification:)),
            name: UIApplication.willEnterForegroundNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(AppStateObserver.appDidBecomeActive(notification:)),
            name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func appWillResignActive(notification: NSNotification) {
        appWillResignActive?()
    }

    @objc private func appDidEnterBackground(notification: NSNotification) {
        appDidEnterBackground?()
    }

    @objc private func appWillEnterForeground(notification: NSNotification) {
        appWillEnterForeground?()
    }

    @objc private func appDidBecomeActive(notification: NSNotification) {
        appDidBecomeActive?()
    }
}

#endif
