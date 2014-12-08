
import Foundation

/// Both serial and concurrent Queues do not guarantee the same Thread is used every time.
/// An exception is made for the main Queue, which always uses the main Thread.
public class Queue : Dispatcher {

  // MARK: Properties

  /// This can only be set if this Queue is serial and created by you.
  public var priority: Priority {
    didSet {
      assert(!isBuiltin, "not allowed to set the priority of a built-in queue")
      _didSetPriority()
    }
  }

  public override var isCurrent: Bool { return kQueueCurrent === self }

  /// If `true`, this Queue always executes one task at a time.
  public let isSerial: Bool

  /// If `true`, this Queue wraps around the main UI queue.
  public var isMain: Bool { return self === Queue.main }

  /// If `true`, this Queue wraps around one of Apple's built-in dispatch queues.
  public let isBuiltin: Bool

  public let core: dispatch_queue_t

  

  // MARK: Methods

  /// Asynchronously adds your task to be executed on this queue.
  /// While your task executes, other tasks cannot execute.
  /// Barriers only work with concurrent queues.
  public func barrier <Out> (job: Job<Void, Out>) -> Job<Void, Out> {
    assert(!isSerial, "a barrier is pointless on a serial queue")
    assert(!isBuiltin, "a barrier cannot be used on a built-in queue")
    dispatch_barrier_async(core) {
      objc_sync_enter(self)
      self._isBlocked = true // Block this queue
      objc_sync_exit(self)

      job.perform()

      objc_sync_enter(self)
      self._isBlocked = false // Unblock this queue
      objc_sync_exit(self)
    }
    return job
  }

  public func barrier (task: Void -> Void) {
    let _ = barrier(Job(task))
  }

  public func suspend () {
    dispatch_suspend(core)
  }

  public func resume () {
    dispatch_resume(core)
  }



  // MARK: Class Variables

  /// Returns `nil` if the current Thread was not created by a Queue; normally this doesn't happen.
  public override class var current: Queue! { return kQueueCurrent }

  public class var main: Queue { return kQueueMain }

  public class var high: Queue { return kQueueHigh }

  public class var medium: Queue { return kQueueMedium }

  public class var low: Queue { return kQueueLow }

  public class var background: Queue { return kQueueBackground }



  // MARK: Class Methods

  /// Creates a new Queue that executes one task at a time.
  public class func serial (_ priority: Priority = .Medium) -> Queue {
    return Queue(true, priority)
  }

  /// Creates a new Queue that executes multiple tasks at once.
  public class func concurrent (_ priority: Priority = .Medium) -> Queue {
    return Queue(false, priority)
  }



  // MARK: Nested Types

  public enum Priority {
    case Main // Most important
    case High
    case Medium
    case Low
    case Background // Least important

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

  /// Initializes one of Apple's built-in queues.
  init (_ priority: Priority) {
    isBuiltin = true
    isSerial = priority == .Main
    core = isSerial ? dispatch_get_main_queue() : dispatch_get_global_queue(priority.core, 0)
    self.priority = priority
    super.init()
    _register()
  }

  /// Initializes a custom queue.
  init (_ serial: Bool, _ priority: Priority) {
    isBuiltin = false
    isSerial = serial
    core = dispatch_queue_create(nil, isSerial ? DISPATCH_QUEUE_SERIAL : DISPATCH_QUEUE_CONCURRENT)
    self.priority = priority
    super.init()
    _didSetPriority()
    _register()
  }

  override func _perform <In, Out> (job: Job<In, Out>, _ asynchronous: Bool) {
    (asynchronous ? dispatch_async : dispatch_sync)(core, job.perform)
  }



  // MARK: Private

  private func _register () {
    dispatch_queue_set_specific(core, &kQueueCurrentKey, pointerFromObject(self), nil)
  }

  private func _didSetPriority () {
    dispatch_set_target_queue(core, priority.builtin.core)
  }
}

var kQueueCurrent: Queue! {
  allocBuiltinQueues()
  return objectFromPointer(dispatch_get_specific(&kQueueCurrentKey))
}

private let kQueueMain = Queue(.Main)

private let kQueueHigh = Queue(.High)

private let kQueueMedium = Queue(.Medium)

private let kQueueLow = Queue(.Low)

private let kQueueBackground = Queue(.Background)

private var kQueueCurrentKey = 0

private var allocBuiltinQueuesOnce = dispatch_once_t()

private func pointerFromObject (object: AnyObject!) -> UnsafeMutablePointer<Void> {
  return object != nil ? UnsafeMutablePointer<Void>(bitPattern: Word(ObjectIdentifier(object).uintValue())) : UnsafeMutablePointer<Void>.null()
}

private func objectFromPointer <T:AnyObject> (pointer: UnsafeMutablePointer<Void>) -> T! {
  return pointer != nil ? Unmanaged<T>.fromOpaque(COpaquePointer(pointer)).takeUnretainedValue() : nil
}

private func allocBuiltinQueues () {
  dispatch_once(&allocBuiltinQueuesOnce) {
    kQueueMain; kQueueHigh; kQueueMedium; kQueueLow; kQueueBackground;
    println("Allocated built-in queues!")
  }
}
