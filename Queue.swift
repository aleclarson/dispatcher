
import Foundation

/// Both serial and concurrent Queues do not guarantee the same Thread is used every time.
/// An exception is made for the main Queue, which always uses the main Thread.
public class Queue {

  // MARK: Properties

  /// This can only be set if this Queue is serial and created by you.
  public var priority: Priority {
    willSet {
      assert(!isBuiltin, "not allowed to set the priority of a built-in queue")
      dispatch_set_target_queue(core, newValue.builtin.core)
    }
  }

  public var isCurrent: Bool { return dispatch_get_specific(&kQueueCurrentKey) == getMutablePointer(self) }

  /// If `true`, this Queue is waiting for a closure to finish before other closures are executed.
  /// The `sync(_:)` and `barrier(_:)` methods cause `isBlocked` to become `true`.
  public var isBlocked: Bool { return _blocked.value }

  /// If `true`, this Queue always executes one closure at a time.
  public let isSerial: Bool

  /// If `true`, this Queue wraps around the main UI queue.
  public var isMain: Bool { return self === Queue.main }

  /// If `true`, this Queue wraps around one of Apple's built-in dispatch queues.
  public let isBuiltin: Bool

  public let core: dispatch_queue_t

  

  // MARK: Methods

  /// Calls the callback asynchronously on this Queue.
  /// The Thread you call this from will continue without waiting for your closure to finish.
  public func async (closure: Void -> Void) {
    dispatch_async(core) { closure() }
  }

  /// If this queue is the current queue, the callback is called immediately.
  /// Else, the callback is called synchronously on this queue.
  public func sync (closure: Void -> Void) {
    isCurrent ? closure() : blockCurrentQueueOrThread { dispatch_sync(self.core, closure) }
  }

  /// If this queue is the current queue, the callback is called immediately.
  /// Else, the callback is called asynchronously on this queue.
  public func csync (closure: Void -> Void) {
    isCurrent ? closure() : async(closure)
  }

  public func suspend () {
    dispatch_suspend(core)
  }

  public func resume () {
    dispatch_resume(core)
  }

  /// Asynchronously adds your closure to be executed on this queue.
  /// While your closure executes, other closures cannot execute.
  /// Barriers only work with concurrent queues.
  public func barrier (closure: Void -> Void) {
    assert(!isSerial, "a barrier is pointless on a serial queue")
    assert(!isBuiltin, "a barrier cannot be used on a built-in queue")
    dispatch_barrier_async(core) {
      self._blocked.value = true
      closure()
      self._blocked.value = false
    }
  }



  // MARK: Class Variables

  /// Returns `nil` if the current Thread was not created by a Queue; normally this doesn't happen.
  public class var current: Queue! {
    let queue = dispatch_get_specific(&kQueueCurrentKey)
    if queue == nil { return nil }
    return Unmanaged<Queue>.fromOpaque(COpaquePointer(queue)).takeUnretainedValue()
  }

  public class var main: Queue { return kQueueMain }

  public class var high: Queue { return kQueueHigh }

  public class var medium: Queue { return kQueueMedium }

  public class var low: Queue { return kQueueLow }

  public class var background: Queue { return kQueueBackground }



  // MARK: Class Methods

  /// Creates a new Queue that executes one closure at a time.
  public class func serial (_ priority: Priority = .Medium) -> Queue {
    return Queue(true, priority)
  }

  /// Creates a new Queue that executes multiple closures at once.
  public class func concurrent (_ priority: Priority = .Medium) -> Queue {
    return Queue(false, priority)
  }



  // MARK: Nested Types

  public enum Priority {
    case Background // Least important
    case Low
    case Medium
    case High
    case Main // Most important

    public var core: dispatch_queue_priority_t! {
      switch self {
        case .Main:       return nil
        case .High:       return DISPATCH_QUEUE_PRIORITY_HIGH
        case .Medium:     return DISPATCH_QUEUE_PRIORITY_DEFAULT
        case .Low:        return DISPATCH_QUEUE_PRIORITY_LOW
        case .Background: return DISPATCH_QUEUE_PRIORITY_BACKGROUND
      }
    }

    /// The built-in Queue associated with this Priority
    public var builtin: Queue {
      switch self {
        case .Main:       return Queue.main
        case .High:       return Queue.high
        case .Medium:     return Queue.medium
        case .Low:        return Queue.low
        case .Background: return Queue.background
      }
    }
  }



  // MARK: Internal

  let _blocked = Lock(false)

  /// Initializes one of Apple's built-in queues.
  init (_ priority: Priority) {
    self.priority = priority
    isSerial = priority == .Main
    core = isSerial ? dispatch_get_main_queue() : dispatch_get_global_queue(priority.core, 0)
    isBuiltin = true
    _register()
  }

  /// Initializes a custom queue.
  init (_ serial: Bool, _ priority: Priority) {
    self.priority = priority
    isSerial = serial
    core = dispatch_queue_create(nil, serial ? DISPATCH_QUEUE_SERIAL : DISPATCH_QUEUE_CONCURRENT)
    isBuiltin = false
    _register()
  }



  // MARK: Private

  private func _register () {
    dispatch_queue_set_specific(core, &kQueueCurrentKey, getMutablePointer(self), nil)
  }
}

private let kQueueMain = Queue(.Main)

private let kQueueHigh = Queue(.High)

private let kQueueMedium = Queue(.Medium)

private let kQueueLow = Queue(.Low)

private let kQueueBackground = Queue(.Background)

var kQueueCurrentKey = 0

func getMutablePointer (object: AnyObject) -> UnsafeMutablePointer<Void> {
  return UnsafeMutablePointer<Void>(bitPattern: Word(ObjectIdentifier(object).uintValue()))
}
