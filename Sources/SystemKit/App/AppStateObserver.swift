//
//  Copyright © 2015 Apparata AB. All rights reserved.
//

#if canImport(UIKit)
import UIKit

/// The AppStateObserver is a convenience object that observes app state
/// notifications and executes the corresponding specified closures.
public final class AppStateObserver {

    public var appWillResignActive: (() -> ())?

    public var appDidEnterBackground: (() -> ())?

    public var appWillEnterForeground: (() -> ())?

    public var appDidBecomeActive: (() -> ())?

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
