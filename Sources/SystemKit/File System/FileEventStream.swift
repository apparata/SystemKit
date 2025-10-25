//
//  Copyright © 2020 Apparata AB. All rights reserved.
//

#if os(macOS)
#if canImport(CoreServices)
import Foundation
import CoreServices
#if canImport(Combine)
import Combine
#endif

// MARK: File Event Stream

/// Example:
///
/// ```
/// do {
///     fileEventStream = try FileEventStream(paths: ["/path/to/monitor"])
///     cancellable = fileEventStream
///         .sink { event in
///             dump(event)
///         }
/// } catch {
///     dump(error)
/// }
/// ```
public class FileEventStream {
    
    public enum Error: Swift.Error {
        case failedToCreateStream
    }
    
    public typealias EventHandler = ([FileEvent]) -> Void
    
    #if canImport(Combine)
    public let subject = PassthroughSubject<FileEvent, Never>()
    #endif
    
    public private(set) var lastEventId: FSEventStreamEventId

    fileprivate var fileEventHandler: EventHandler?
    
    private var stream: FSEventStreamRef!
    
    /// A per-host event stream consists of events whose IDs are increasing
    /// with respect to other events on that host. These IDs are guaranteed
    /// to be unique with one exception: if additional disks are added from
    /// another computer that was also running OS X v10.5 or later,
    /// historical IDs may conflict between these volumes. Any new events
    /// will automatically start after the highest-numbered historical ID
    /// for any attached drive.
    ///
    /// - Parameter paths: Array of strings, each specifying a path to a
    ///     directory, signifying the root of a file system hierarchy to be
    ///     watched for modifications.
    /// - Parameter sinceWhen: The service will supply events that have
    ///     happened after the given event ID. To ask for events "since now"
    ///     pass the constant `.sinceNow`. Often, clients will supply the
    ///     highest-numbered `FSEventStreamEventId` they have received in a
    ///     callback, which they can obtain via the
    ///     `FSEventStreamGetLatestEventId()` accessor. Do not pass zero for
    ///     sinceWhen, unless you want to receive events for every directory
    ///     modified since "the beginning of time" -- an unlikely scenario.
    /// - Parameter latency: The number of seconds the service should wait
    ///     after hearing about an event from the kernel before passing it
    ///     along to the client via its callback. Specifying a larger value
    ///     may result in more effective temporal coalescing, resulting in
    ///     fewer callbacks and greater overall efficiency.
    /// - Parameter flags: Flags that modify the behavior of the stream being
    ///     created.
    public init(paths: [String],
                sinceWhen: FSEventStreamEventId = .sinceNow,
                latency: TimeInterval = 1,
                flags: Flags = .none,
                eventHandler: EventHandler? = nil) throws {
        fileEventHandler = eventHandler
        lastEventId = sinceWhen
        
        stream = try createPerHostStream(
            paths: paths,
            sinceWhen: sinceWhen,
            latency: latency,
            flags: flags.rawValue)
        
        FSEventStreamScheduleWithRunLoop(
            stream,
            CFRunLoopGetCurrent(),
            CFRunLoopMode.defaultMode.rawValue)
        
        FSEventStreamStart(stream)
    }
    
    /// A per-host event stream consists of events whose IDs are increasing
    /// with respect to other events on that host. These IDs are guaranteed
    /// to be unique with one exception: if additional disks are added from
    /// another computer that was also running OS X v10.5 or later,
    /// historical IDs may conflict between these volumes. Any new events
    /// will automatically start after the highest-numbered historical ID
    /// for any attached drive.
    ///
    /// - Parameter paths: Array of strings, each specifying a path to a
    ///     directory, signifying the root of a file system hierarchy to be
    ///     watched for modifications.
    /// - Parameter sinceWhen: The service will supply events that have
    ///     happened after the given event ID. To ask for events "since now"
    ///     pass the constant `.sinceNow`. Often, clients will supply the
    ///     highest-numbered `FSEventStreamEventId` they have received in a
    ///     callback, which they can obtain via the
    ///     `FSEventStreamGetLatestEventId()` accessor. Do not pass zero for
    ///     sinceWhen, unless you want to receive events for every directory
    ///     modified since "the beginning of time" -- an unlikely scenario.
    /// - Parameter latency: The number of seconds the service should wait
    ///     after hearing about an event from the kernel before passing it
    ///     along to the client via its callback. Specifying a larger value
    ///     may result in more effective temporal coalescing, resulting in
    ///     fewer callbacks and greater overall efficiency.
    /// - Parameter flags: Flags that modify the behavior of the stream being
    ///     created.
    public convenience init(paths: [Path],
                            sinceWhen: FSEventStreamEventId = .sinceNow,
                            latency: TimeInterval = 1,
                            flags: Flags = .none,
                            eventHandler: EventHandler? = nil) throws {
        try self.init(paths: paths.map(\.string),
                      sinceWhen: sinceWhen,
                      latency: latency,
                      flags: flags,
                      eventHandler: eventHandler)
    }

    /// A per-disk event stream, by contrast, consists of events whose IDs
    /// are increasing with respect to previous events on that disk. It
    /// does not have any relationship with other events on other disks,
    /// and thus you must create a separate event stream for each physical
    /// device that you wish to monitor.
    ///
    /// - Parameter device: A `dev_t` corresponding to the device which you
    ///     want to receive notifications from. The `dev_t` is the same as the
    ///     `st_dev` field from a stat structure of a file on that device or
    ///     the `f_fsid[0]` field of a statfs structure. If the value of device
    ///     is zero, it is ignored.
    /// - Parameter paths: Array of strings, each specifying a path to a
    ///     directory, signifying the root of a file system hierarchy to be
    ///     watched for modifications.
    /// - Parameter sinceWhen: The service will supply events that have
    ///     happened after the given event ID. To ask for events "since now"
    ///     pass the constant `.sinceNow`. Often, clients will supply the
    ///     highest-numbered `FSEventStreamEventId` they have received in a
    ///     callback, which they can obtain via the
    ///     `FSEventStreamGetLatestEventId()` accessor. Do not pass zero for
    ///     sinceWhen, unless you want to receive events for every directory
    ///     modified since "the beginning of time" -- an unlikely scenario.
    /// - Parameter latency: The number of seconds the service should wait
    ///     after hearing about an event from the kernel before passing it
    ///     along to the client via its callback. Specifying a larger value
    ///     may result in more effective temporal coalescing, resulting in
    ///     fewer callbacks and greater overall efficiency.
    /// - Parameter flags: Flags that modify the behavior of the stream being
    ///     created.
    public init(device: dev_t,
                paths: [String],
                sinceWhen: FSEventStreamEventId = .sinceNow,
                latency: TimeInterval = 1,
                flags: Flags = .none,
                eventHandler: EventHandler? = nil) throws {
        fileEventHandler = eventHandler
        lastEventId = sinceWhen
        
        stream = try createPerDevice(
            device: device,
            paths: paths,
            sinceWhen: sinceWhen,
            latency: latency,
            flags: flags.rawValue)
        
        FSEventStreamScheduleWithRunLoop(
            stream,
            CFRunLoopGetCurrent(),
            CFRunLoopMode.defaultMode.rawValue)
        
        FSEventStreamStart(stream)
    }
    
    /// A per-disk event stream, by contrast, consists of events whose IDs
    /// are increasing with respect to previous events on that disk. It
    /// does not have any relationship with other events on other disks,
    /// and thus you must create a separate event stream for each physical
    /// device that you wish to monitor.
    ///
    /// - Parameter device: A `dev_t` corresponding to the device which you
    ///     want to receive notifications from. The `dev_t` is the same as the
    ///     `st_dev` field from a stat structure of a file on that device or
    ///     the `f_fsid[0]` field of a statfs structure. If the value of device
    ///     is zero, it is ignored.
    /// - Parameter paths: Array of strings, each specifying a path to a
    ///     directory, signifying the root of a file system hierarchy to be
    ///     watched for modifications.
    /// - Parameter sinceWhen: The service will supply events that have
    ///     happened after the given event ID. To ask for events "since now"
    ///     pass the constant `.sinceNow`. Often, clients will supply the
    ///     highest-numbered `FSEventStreamEventId` they have received in a
    ///     callback, which they can obtain via the
    ///     `FSEventStreamGetLatestEventId()` accessor. Do not pass zero for
    ///     sinceWhen, unless you want to receive events for every directory
    ///     modified since "the beginning of time" -- an unlikely scenario.
    /// - Parameter latency: The number of seconds the service should wait
    ///     after hearing about an event from the kernel before passing it
    ///     along to the client via its callback. Specifying a larger value
    ///     may result in more effective temporal coalescing, resulting in
    ///     fewer callbacks and greater overall efficiency.
    /// - Parameter flags: Flags that modify the behavior of the stream being
    ///     created.
    public convenience init(device: dev_t,
                            paths: [Path],
                            sinceWhen: FSEventStreamEventId = .sinceNow,
                            latency: TimeInterval = 1,
                            flags: Flags = .none,
                            eventHandler: EventHandler? = nil) throws {
        try self.init(device: device,
                      paths: paths.map(\.string),
                      sinceWhen: sinceWhen,
                      latency: latency,
                      flags: flags,
                      eventHandler: eventHandler)
    }
    
    deinit {
        FSEventStreamStop(stream)
        FSEventStreamInvalidate(stream)
        FSEventStreamRelease(stream)
    }
    
    /// Asks the FS Events service to flush out any events that have
    /// occurred but have not yet been delivered, due to the latency
    /// parameter that was supplied when the stream was created. This
    /// flushing occurs synchronously -- by the time this call returns,
    /// your callback will have been invoked for every event that had
    /// already occurred at the time you made this call.
    public func flush() {
        FSEventStreamFlushSync(stream)
    }
    
    /// Asks the FS Events service to flush out any events that have
    /// occurred but have not yet been delivered, due to the latency
    /// parameter that was supplied when the stream was created. This
    /// flushing occurs asynchronously -- do not expect the events to
    /// have already been delivered by the time this call returns.
    public func flushAsync() {
        FSEventStreamFlushAsync(stream)
    }
    
    private func createPerHostStream(
        paths: [String],
        sinceWhen: FSEventStreamEventId,
        latency: TimeInterval,
        flags: FSEventStreamCreateFlags
    ) throws -> FSEventStreamRef {
        
        var context = FSEventStreamContext()
        context.info = unsafeBitCast(self, to: UnsafeMutableRawPointer.self)
                
        guard let stream = FSEventStreamCreate(
            nil,
            eventCallback,
            &context,
            paths as CFArray,
            sinceWhen,
            latency,
            flags | FSEventStreamCreateFlags(kFSEventStreamCreateFlagUseCFTypes)) else {
            throw Error.failedToCreateStream
        }
        
        return stream
    }
    
    private func createPerDevice(
        device: dev_t,
        paths: [String],
        sinceWhen: FSEventStreamEventId,
        latency: TimeInterval,
        flags: FSEventStreamCreateFlags
    ) throws -> FSEventStreamRef {

        var context = FSEventStreamContext()
        context.info = Unmanaged.passUnretained(self).toOpaque()
        context.info = unsafeBitCast(self, to: UnsafeMutableRawPointer.self)
        
        guard let stream = FSEventStreamCreateRelativeToDevice(
            nil,
            eventCallback,
            &context,
            device,
            paths as CFArray,
            sinceWhen,
            latency,
            flags | FSEventStreamCreateFlags(kFSEventStreamCreateFlagUseCFTypes)) else {
                throw Error.failedToCreateStream
        }
        
        return stream
    }
}

// MARK: - Combine Publisher

#if canImport(Combine)
extension FileEventStream: Publisher {
        
    public typealias Output = FileEvent
    
    public typealias Failure = Never
    
    public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        subject.receive(subscriber: subscriber)
    }
}
#endif

// MARK: - Event Callback

private func eventCallback(
    stream: ConstFSEventStreamRef,
    clientCallbackInfo: UnsafeMutableRawPointer?,
    numEvents: Int,
    eventPaths: UnsafeMutableRawPointer,
    eventFlags: UnsafePointer<FSEventStreamEventFlags>,
    eventIDs: UnsafePointer<FSEventStreamEventId>) {

    guard let streamPointer = clientCallbackInfo else {
        return
    }
    
    let stream = Unmanaged<FileEventStream>
        .fromOpaque(streamPointer)
        .takeUnretainedValue()
    
    guard let paths = unsafeBitCast(eventPaths, to: NSArray.self) as? [String] else {
        return
    }
        
    var events: [FileEvent] = []
    for i in 0..<numEvents {
        let path = paths[i]
        let flags = FileEvent.Flags(rawValue: eventFlags[i])
        let event = FileEvent(path: path, flags: flags)
        events.append(event)
        
    }
    
    stream.fileEventHandler?(events)
    #if canImport(Combine)
    for event in events {
        stream.subject.send(event)
    }
    #endif
}

#endif

// MARK: - Event ID

public extension FSEventStreamEventId {
    
    static let sinceNow = FSEventStreamEventId(kFSEventStreamEventIdSinceNow)
}

// MARK: - Create Flags

public extension FileEventStream {
    
    struct Flags: Sendable, OptionSet {
                
        /// The default.
        public static let none = Flags(kFSEventStreamCreateFlagNone)
                
        /// Affects the meaning of the latency parameter. If you specify this
        /// flag and more than latency seconds have elapsed since the last
        /// event, your app will receive the event immediately. The delivery
        /// of the event resets the latency timer and any further events will
        /// be delivered after latency seconds have elapsed. This flag is
        /// useful for apps that are interactive and want to react immediately
        /// to changes but avoid getting swamped by notifications when changes
        /// are occurringin rapid succession. If you do not specify this flag,
        /// then when an event occurs after a period of no events, the latency
        /// timer is started. Any events that occur during the next latency
        /// seconds will be delivered as one group (including that first
        /// event). The delivery of the group of events resets the latency
        /// timer and any further events will be delivered after latency
        /// seconds. This is the default behavior and is more appropriate for
        /// background, daemon or batch processing apps.
        public static let noDefer = Flags(kFSEventStreamCreateFlagNoDefer)
        
        /// Request notifications of changes along the path to the path(s)
        /// you're watching. For example, with this flag, if you watch
        /// "/foo/bar" and it is renamed to "/foo/bar.old", you would receive
        /// a RootChanged event. The same is true if the directory "/foo" were
        /// renamed. The event you receive is a special event: the path for
        /// the event is the original path you specified, the flag
        /// kFSEventStreamEventFlagRootChanged is set and event ID is zero.
        /// RootChanged events are useful to indicate that you should rescan a
        /// particular hierarchy because it changed completely (as opposed to
        /// the things inside of it changing). If you want to track the
        /// current location of a directory, it is best to open the directory
        /// before creating the stream so that you have a file descriptor for
        /// it and can issue an F_GETPATH fcntl() to find the current path.
        public static let watchRoot = Flags(kFSEventStreamCreateFlagWatchRoot)
        
        /// Don't send events that were triggered by the current process. This
        /// is useful for reducing the volume of events that are sent. It is
        /// only useful if your process might modify the file system hierarchy
        /// beneath the path(s) being monitored. Note: this has no effect on
        /// historical events, i.e., those delivered before the HistoryDone
        /// sentinel event.  Also, this does not apply to RootChanged events
        /// because the WatchRoot feature uses a separate mechanism that is
        /// unable to provide information about the responsible process.
        public static let ignoreSelf = Flags(kFSEventStreamCreateFlagIgnoreSelf)
        
        /// Request file-level notifications.  Your stream will receive events
        /// about individual files in the hierarchy you're watching instead of
        /// only receiving directory level notifications.  Use this flag with
        /// care as it will generate significantly more events than without it.
        public static let fileEvents = Flags(kFSEventStreamCreateFlagFileEvents)
        
        /// Tag events that were triggered by the current process with the
        /// "OwnEvent" flag. This is only useful if your process might modify
        /// the file system hierarchy beneath the path(s) being monitored and
        ///  you wish to know which events were triggered by your process.
        ///
        /// Note: this has no effect on historical events, i.e., those
        /// delivered before the HistoryDone sentinel event.
        public static let markSelf = Flags(kFSEventStreamCreateFlagMarkSelf)
                
        public let rawValue: FSEventStreamCreateFlags
        
        public init(rawValue: FSEventStreamCreateFlags) {
            self.rawValue = rawValue
        }
        
        public init(_ flags: Int) {
            self.rawValue = FSEventStreamCreateFlags(flags)
        }
    }
}

// MARK: File Event

public struct FileEvent {
    public let path: String
    public let flags: Flags
    
    public init(path: String, flags: Flags) {
        self.path = path
        self.flags = flags
    }
}

// MARK: Event Flags

public extension FileEvent {
        
    struct Flags: Sendable, OptionSet, CustomStringConvertible {

        /// Your application must rescan not just the directory given in the
        /// event, but all its children, recursively. This can happen if there
        /// was a problem whereby events were coalesced hierarchically. For
        /// example, an event in `/Users/jsmith/Music` and an event in
        /// `/Users/jsmith/Pictures` might be coalesced into an event with this
        /// flag set and `path=/Users/jsmith`. If this flag is set you may be
        /// able to get an idea of whether the bottleneck happened in the kernel
        /// (less likely) or in your client (more likely) by checking for the
        /// presence of the informational flags `.userDropped` or `.kernelDropped`.
        static let mustScanSubDirs = Flags(kFSEventStreamEventFlagMustScanSubDirs)
        
        /// The `.userDropped` or `.kernelDropped` flags may be set in addition
        /// to the `.mustScanSubDirs` flag to indicate that a problem occurred in
        /// buffering the events (the particular flag set indicates where the
        /// problem occurred) and that the client must do a full scan of any
        /// directories (and their subdirectories, recursively) being monitored by
        /// this stream. If you asked to monitor multiple paths with this stream
        /// then you will be notified about all of them. Your code need only check
        /// for the `.mustScanSubDirs` flag; these flags (if present) only provide
        /// information to help you diagnose the problem.
        static let userDropped = Flags(kFSEventStreamEventFlagUserDropped)
        
        /// The `.userDropped` or `.kernelDropped` flags may be set in addition
        /// to the `.mustScanSubDirs` flag to indicate that a problem occurred in
        /// buffering the events (the particular flag set indicates where the
        /// problem occurred) and that the client must do a full scan of any
        /// directories (and their subdirectories, recursively) being monitored by
        /// this stream. If you asked to monitor multiple paths with this stream
        /// then you will be notified about all of them. Your code need only check
        /// for the `.mustScanSubDirs` flag; these flags (if present) only provide
        /// information to help you diagnose the problem.
        static let kernelDropped = Flags(kFSEventStreamEventFlagKernelDropped)
        
        /// If `.idsWrapped` is set, it means the 64-bit event ID counter wrapped
        /// around. As a result, previously-issued event IDs are no longer valid
        /// arguments for the sinceWhen parameter of the `FSEventStreamCreate...()`
        /// functions.
        static let eventIdsWrapped = Flags(kFSEventStreamEventFlagEventIdsWrapped)
        
        /// Denotes a sentinel event sent to mark the end of the "historical"
        /// events sent as a result of specifying a `sinceWhen` value in the
        /// constructor that created this event stream. (It will not be sent if
        /// `.sinceNow` was passed for `sinceWhen`.) After invoking the client's
        /// callback with all the "historical" events that occurred before now, the
        /// client's callback will be invoked with an event where the `.historyDone`
        /// flag is set. The client should ignore the path supplied in callback.
        static let historyDone = Flags(kFSEventStreamEventFlagHistoryDone)
        
        /// Denotes a special event sent when there is a change to one of the
        /// directories along the path to one of the directories you asked to
        /// watch. When this flag is set, the event ID is zero and the path
        /// corresponds to one of the paths you asked to watch (specifically,
        /// the one that changed). The path may no longer exist because it or
        /// one of its parents was deleted or renamed. Events with this flag
        /// set will only be sent if you passed the flag `.watchRoot` to
        /// the constructor when you created the stream.
        static let rootChanged = Flags(kFSEventStreamEventFlagRootChanged)
        
        /// Denotes a special event sent when a volume is mounted underneath
        /// one of the paths being monitored. The path in the event is the
        /// path to the newly-mounted volume. You will receive one of these
        /// notifications for every volume mount event inside the kernel
        /// (independent of `DiskArbitration`). Beware that a newly-mounted
        /// volume could contain an arbitrarily large directory hierarchy.
        /// Avoid pitfalls like triggering a recursive scan of a non-local
        /// filesystem, which you can detect by checking for the absence of
        /// the `MNT_LOCAL` flag in the `f_flags` returned by `statfs()`. Also be
        /// aware of the `MNT_DONTBROWSE` flag that is set for volumes which
        /// should not be displayed by user interface elements.
        static let mount = Flags(kFSEventStreamEventFlagMount)

        /// Denotes a special event sent when a volume is unmounted underneath
        /// one of the paths being monitored. The path in the event is the
        /// path to the directory from which the volume was unmounted. You
        /// will receive one of these notifications for every volume unmount
        /// event inside the kernel. This is not a substitute for the
        /// notifications provided by the `DiskArbitration` framework; you only
        /// get notified after the unmount has occurred. Beware that
        /// unmounting a volume could uncover an arbitrarily large directory
        /// hierarchy, although macOS never does that.
        static let unmount = Flags(kFSEventStreamEventFlagUnmount)
        
        /// Object was created at the specific path supplied in this event.
        /// (Only ever set if `.fileEvents` was set when stream was created.)
        static let itemCreated = Flags(kFSEventStreamEventFlagItemCreated)
        
        /// Object was removed at the specific path supplied in this event.
        /// (Only ever set if `.fileEvents` was set when stream was created.)
        static let itemRemoved = Flags(kFSEventStreamEventFlagItemRemoved)
        
        /// Object at specifed path in this event had its metadata modified.
        /// (Only ever set if `.fileEvents` was set when stream was created.)
        static let itemInodeMetaMod = Flags(kFSEventStreamEventFlagItemInodeMetaMod)
        
        /// Object was renamed at the specific path supplied in this event.
        /// (Only ever set if `.fileEvents` was set when stream was created.)
        static let itemRenamed = Flags(kFSEventStreamEventFlagItemRenamed)
        
        /// Object at specified path in this event had its data modified.
        /// (Only ever set if `.fileEvents` was set when stream was created.)
        static let itemModified = Flags(kFSEventStreamEventFlagItemModified)
        
        /// Object at specifed path in this event had its FinderInfo data modified.
        /// (Only ever set if `.fileEvents` was set when stream was created.)
        static let itemFinderInfoMod = Flags(kFSEventStreamEventFlagItemFinderInfoMod)
        
        /// Object at specifed path in this event had its ownership changed.
        /// (Only ever set if `.fileEvents` was set when stream was created.)
        static let itemChangeOwner = Flags(kFSEventStreamEventFlagItemChangeOwner)
        
        /// Object at specified path had its extended attributes modified.
        /// (Only ever set if `.fileEvents` was set when stream was created.)
        static let itemXattrMod = Flags(kFSEventStreamEventFlagItemXattrMod)
        
        /// Object at the specific path supplied in this event is a regular file.
        /// (Only ever set if `.fileEvents` was set when stream was created.)
        static let itemIsFile = Flags(kFSEventStreamEventFlagItemIsFile)
        
        /// Object at the specified path in this event is a directory.
        /// (Only ever set if `.fileEvents` was set when stream was created.)
        static let itemIsDir = Flags(kFSEventStreamEventFlagItemIsDir)
        
        /// Object at the specified path in this event is a symbolic link.
        /// (Only ever set if `.fileEvents` was set when stream was created.)
        static let itemIsSymlink = Flags(kFSEventStreamEventFlagItemIsSymlink)
        
        /// Indicates the event was triggered by the current process.
        /// (Only ever set if `.fileEvents` was set when stream was created.)
        static let ownEvent = Flags(kFSEventStreamEventFlagOwnEvent)
        
        /// Object at the specified path supplied in this event is a hard link.
        /// (Only ever set if `.fileEvents` was set when stream was created.)
        static let itemIsHardLink = Flags(kFSEventStreamEventFlagItemIsHardlink)
        
        /// Object at the specified path in this event is a clone or was cloned.
        /// (Only ever set if `.fileEvents` was set when stream was created.)
        static let itemIsLastHardLink = Flags(kFSEventStreamEventFlagItemIsLastHardlink)

        public var description: String {
            var strings: [String] = []
            if contains(.mustScanSubDirs) {
                strings.append("mustScanSubDirs")
            }
            if contains(.userDropped) {
                strings.append("userDropped")
            }
            if contains(.kernelDropped) {
                strings.append("kernelDropped")
            }
            if contains(.eventIdsWrapped) {
                strings.append("eventIdsWrapped")
            }
            if contains(.historyDone) {
                strings.append("historyDone")
            }
            if contains(.rootChanged) {
                strings.append("rootChanged")
            }
            if contains(.mount) {
                strings.append("mount")
            }
            if contains(.unmount) {
                strings.append("unmount")
            }
            if contains(.itemCreated) {
                strings.append("itemCreated")
            }
            if contains(.itemRemoved) {
                strings.append("itemRemoved")
            }
            if contains(.itemInodeMetaMod) {
                strings.append("itemInodeMetaMod")
            }
            if contains(.itemRenamed) {
                strings.append("itemRenamed")
            }
            if contains(.itemModified) {
                strings.append("itemModified")
            }
            if contains(.itemFinderInfoMod) {
                strings.append("itemFinderInfoMod")
            }
            if contains(.itemChangeOwner) {
                strings.append("itemChangeOwner")
            }
            if contains(.itemXattrMod) {
                strings.append("itemXattrMod")
            }
            if contains(.itemIsFile) {
                strings.append("itemIsFile")
            }
            if contains(.itemIsDir) {
                strings.append("itemIsDir")
            }
            if contains(.itemIsSymlink) {
                strings.append("itemIsSymlink")
            }
            if contains(.ownEvent) {
                strings.append("ownEvent")
            }
            if contains(.itemIsHardLink) {
                strings.append("itemIsHardLink")
            }
            if contains(.itemIsLastHardLink) {
                strings.append("itemIsLastHardLink")
            }
            return "[\(strings.joined(separator: ", "))]"
        }
        
        public let rawValue: FSEventStreamEventFlags
        
        public init(rawValue: FSEventStreamEventFlags) {
            self.rawValue = rawValue
        }
        
        public init(_ flags: Int) {
            self.rawValue = FSEventStreamEventFlags(flags)
        }
    }
}
#endif
